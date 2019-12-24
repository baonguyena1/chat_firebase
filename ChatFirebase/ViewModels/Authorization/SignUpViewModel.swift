//
//  SignUpViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseDatabase

class SignUpViewModel: BaseViewModel {
    var emailText = BehaviorSubject<String>(value: "")
    var passwordText = BehaviorSubject<String>(value: "")
    var confirmPasswordText = BehaviorSubject<String>(value: "")
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(emailText.asObservable(), passwordText.asObservable(), confirmPasswordText.asObservable()) { (email, password, confirmPassword) in
            return password == confirmPassword && password.count >= 6 && email.isValidEmail()
        }
    }
    
    private var bag = DisposeBag()
    
    private(set) var user = PublishRelay<User>()
    
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    
    func singUp(email: String, password: String) {
        FireBaseManager.shared.signOut()
        let auth = FireBaseManager.shared.auth        
        rx_isLoading.accept(true)
        auth.rx.createUser(withEmail: email, password: password)
            .subscribe(onNext: { [weak self] (result) in
                self?.user.accept(result.user)
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
}
