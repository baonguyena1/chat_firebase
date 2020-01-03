//
//  UpdateUserInforViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/24/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFirebase
import FirebaseStorage
import FirebaseFirestore

class UpdateUserInforViewModel: BaseViewModel {
    
    var nameSubject = BehaviorSubject<String>(value: "")
    var chooseAvatarSubject = BehaviorSubject<Bool>(value: false)
    
    private var bag = DisposeBag()
    
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    private(set) lazy var updatedInfoStatus = PublishRelay<Bool>()
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(nameSubject.asObservable(), chooseAvatarSubject.asObservable()) { (name, chooseAvatar) in
            return !name.isEmpty && chooseAvatar
        }
    }
    
    func updateUserInfo(userId: String, image: UIImage, name: String, email: String) {
        let imageName = UUID().uuidString.lowercased()
        let reference = FireBaseManager.shared.userProfileStorage.child(userId).child(imageName + ".png")
        var values: [String: Any] = [
            KeyPath.kDocumentID: userId,
            KeyPath.kEmail: email,
            KeyPath.kDisplayName: name,
            KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970
        ]
        
        rx_isLoading.accept(true)
        FireBaseManager.shared.uploadImage(image, ref: reference)
            .flatMapLatest { (status) -> Observable<String> in
                if status {
                    return FireBaseManager.shared.getUrl(reference: reference)
                } else {
                    return Observable.just("")
                }
            }
            .flatMapLatest { (avatarUrl) -> Observable<Void> in
                if !avatarUrl.isEmpty {
                    values[KeyPath.kAvatar] = avatarUrl
                }
                let user = FireBaseManager.shared.usersCollection.document(userId)
                return self.uploadUserInfo(values, document: user)
            }
            .subscribe(onNext: { [weak self] () in
                self?.updatedInfoStatus.accept(true)
            }, onError: { [weak self] (error) in
                Logger.error(error.localizedDescription)
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)

    }
    
    private func uploadUserInfo(_ values: [String: Any], document: DocumentReference) -> Observable<Void> {
        return document.rx.setData(values, merge: true)
    }
    
}
