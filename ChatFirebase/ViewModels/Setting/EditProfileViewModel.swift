//
//  EditProfileViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/3/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewModel: BaseViewModel {
    var rx_isLoading = PublishRelay<Bool>()
    
    var rx_error = PublishRelay<String>()
    
    var editProfileSuccess = PublishRelay<Void>()
    
    private let bag = DisposeBag()
    
    func edit(_ image: UIImage, name: String?, previousImageUrl: String) {
        guard let userId = FireBaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let storageRef = FireBaseManager.shared.userProfileStorage.child(userId).child(UUID().uuidString.lowercased() + ".png")
        
        rx_isLoading.accept(true)
        FireBaseManager.shared.uploadGetDeletePreviousImage(image, previousLink: previousImageUrl, reference: storageRef)
            .flatMap { (url) -> Observable<Void> in
                var data: [String: Any] = [KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970]
                if let name = name {
                    data[KeyPath.kDisplayName] = name
                }
                if !url.isEmpty {
                    data[KeyPath.kAvatar] = url
                }
                let userRef = FireBaseManager.shared.usersCollection.document(userId)
                return userRef.rx.updateData(data)
            }
            .subscribe(onNext: { [weak self] (_) in
                Logger.log("")
                self?.editProfileSuccess.accept(())
            }, onError: { [weak self] (error) in
                Logger.error(error.localizedDescription)
                self?.rx_error.accept(error.localizedDescription)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
}
