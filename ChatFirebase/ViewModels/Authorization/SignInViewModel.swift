//
//  SignInViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/23/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SignInViewModel: BaseViewModel {
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    
    private let bag = DisposeBag()
    
    var emailSubject = BehaviorSubject<String>(value: "")
    var passwordSubject = BehaviorSubject<String>(value: "")
    
    var loginSubject = PublishSubject<Void>()
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(emailSubject.asObservable(), passwordSubject.asObservable()) { (email, password) in
            return !password.isEmpty && email.isValidEmail()
        }
    }
    
    func signIn(email: String, password: String) {
        let auth = FireBaseManager.shared.auth
        rx_isLoading.accept(true)
        auth.rx.signIn(withEmail: email, password: password)
            .subscribe(onNext: { [weak self] (result) in
                Logger.log("\(result)")
                self?.loginSubject.onNext(())
            }, onError: { [weak self] (error) in
                Logger.error(error.localizedDescription)
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
}
