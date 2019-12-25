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
            KeyPath.kId: userId,
            KeyPath.kEmail: email,
            KeyPath.kDisplayName: name,
            KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970
        ]
        
        func uploadInfo() {
            let userReference = FireBaseManager.shared.usersCollection.document(userId)
            userReference.rx
                .setData(values)
                .subscribe(onNext: { [weak self] (_) in
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
        
        rx_isLoading.accept(true)
        uploadImage(image, reference: reference) { [weak self] status in
            if status {
                self?.getUrl(reference: reference) { url in
                    if !url.isEmpty {
                        values[KeyPath.kAvatar] = url
                    }
                    uploadInfo()
                }
            } else {
                uploadInfo()
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, reference: StorageReference, completion: @escaping ((Bool) -> Void)) {
        guard let imageData = image.pngData() else {
            return completion(false)
        }
        var status = false
        reference.rx.putData(imageData)
            .subscribe(onNext: { (metaData) in
                status = true
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: {
                completion(status)
            })
            .disposed(by: bag)
    }
    
    private func getUrl(reference: StorageReference, completion: @escaping ((String) -> Void)) {
        var urlString = ""
        reference.rx
            .downloadURL()
            .subscribe(onNext: { (url) in
                urlString = url.absoluteString
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: {
                completion(urlString)
            })
            .disposed(by: bag)
    }
}
