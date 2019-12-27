//
//  LoginUserManager.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/30/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginUserManager {
    static let shared = LoginUserManager()
    
    private(set) lazy var profile = BehaviorRelay<User>(value: User(json: [:]))
    
    private let bag = DisposeBag()
    
    private init() {
        guard let userId = FireBaseManager.shared.auth.currentUser?.uid else {
            return
        }
        self.observeProfile(userId: userId)
    }
    
    private func observeProfile(userId: String) {
        let profile = FireBaseManager.shared.usersCollection.document(userId)
        profile.rx
            .listen()
            .subscribe(onNext: { [weak self] (snapshot) in
                if let data = snapshot.data() {
                    let profile = User(json: data)
                    self?.profile.accept(profile)
                }
                }, onError: { (error) in
                    Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}
