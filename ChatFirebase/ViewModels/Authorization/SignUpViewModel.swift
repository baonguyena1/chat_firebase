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

struct SignUpViewModel: BaseViewModel {
    
    var emailText = PublishSubject<String>()
    var passwordText = PublishSubject<String>()
    var confirmPasswordText = PublishSubject<String>()
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(emailText.asObservable(), passwordText.asObservable(), confirmPasswordText.asObservable()) { (email, password, confirmPassword) in
            return password == confirmPassword && password.count >= 6 && email.isValidEmail()
        }
    }
}
