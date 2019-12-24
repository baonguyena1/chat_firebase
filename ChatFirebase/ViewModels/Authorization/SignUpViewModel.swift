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
    var nameText = PublishSubject<String>()
    var emailText = PublishSubject<String>()
    var passwordText = PublishSubject<String>()
    var confirmPasswordText = PublishSubject<String>()
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(nameText.asObservable(), emailText.asObservable(), passwordText.asObservable(), confirmPasswordText.asObservable()) { (name, email, password, confirmPassword) in
            return password == confirmPassword && password.count >= 6 && email.isValidEmail() && !name.isEmpty
        }
    }
    
    private var bag = DisposeBag()
    
    private(set) var user = PublishRelay<User>()
    
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    
    func singUp(email: String, password: String, name: String) {
        FireBaseManager.shared.signOut()

        let auth = FireBaseManager.shared.auth        
        rx_isLoading.accept(true)
        auth.rx.createUser(withEmail: email, password: password)
            .subscribe(onNext: { [weak self] (result) in
                self?.updateUser(user: result.user, name: name)
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    private func updateUser(user: User, name: String) {
        let usersCollection = FireBaseManager.shared.usersCollection
        usersCollection
            .document(user.uid)
            .setData([KeyPath.kDisplayName: name]) { [weak self] (error) in
                if let error = error {
                    Logger.error(error.localizedDescription)
                    self?.rx_error.accept(error.localizedDescription)
                }
                self?.user.accept(user)
            }
    }
}
