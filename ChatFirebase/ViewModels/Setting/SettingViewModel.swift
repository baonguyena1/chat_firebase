//
//  SettingViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel: BaseViewModel {
    
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    
    private(set) lazy var signOutEvent = PublishRelay<Void>()
    private(set) lazy var profile = PublishRelay<User>()
    
    private let bag = DisposeBag()
    
    func observeProfile(userId: String) {
        let profile = FireBaseManager.shared.usersCollection.document(userId)
        profile.rx
            .listen()
            .subscribe(onNext: { [weak self] (snapshot) in
                if let data = snapshot.data() {
                    let profile = User(from: data)
                    self?.profile.accept(profile)
                }
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func signOut() {
        let auth = FireBaseManager.shared.auth
        rx_isLoading.accept(true)
        do {
            try auth.signOut()
            rx_isLoading.accept(false)
            signOutEvent.accept(())
        } catch let error {
            rx_error.accept(error.localizedDescription)
        }
    }
}
