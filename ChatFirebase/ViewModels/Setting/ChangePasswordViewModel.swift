//
//  ChangePasswordViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/3/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFirebase
import FirebaseAuth

class ChangePasswordViewModel: BaseViewModel {
    var rx_isLoading = PublishRelay<Bool>()
    
    var rx_error = PublishRelay<String>()
    
    var changePasswordSuccess = PublishRelay<Void>()
    
    var passwordSubject = BehaviorRelay<String>(value: "")
    
    var oldPasswordSubject = BehaviorRelay<String>(value: "")
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(oldPasswordSubject.asObservable(), passwordSubject.asObservable()) { (old, new) in
            return !old.isEmpty && !new.isEmpty && new.count >= 6
        }
    }
    
    private let bag = DisposeBag()
    
    func changePassword(oldPass: String, password: String, forUser userId: String) {
        guard let user = FireBaseManager.shared.auth.currentUser, let email = user.email else { return }
        rx_isLoading.accept(true)
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPass)
        user.rx.reauthenticateAndRetrieveData(with: credential)
            .flatMap { (result) -> Observable<Void> in
                user.rx.updatePassword(to: password)
            }
            .subscribe(onNext: { [weak self] (_) in
                self?.changePasswordSuccess.accept(())
                }, onError: { [weak self] (error) in
                    self?.rx_error.accept(error.localizedDescription)
                    self?.rx_isLoading.accept(false)
                }, onCompleted: { [weak self] in
                    self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
}
