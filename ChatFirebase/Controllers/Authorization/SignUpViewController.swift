//
//  SignUpViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxFirebaseAuthentication
import FirebaseAuth
import MBProgressHUD

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var viewModel: SignUpViewModel!
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func setupViewModel() {
        viewModel = SignUpViewModel()
        _ = emailTextField.rx.text.orEmpty.bind(to: viewModel.emailText)
        _ = passwordTextField.rx.text.orEmpty.bind(to: viewModel.passwordText)
        _ = confirmPasswordTextField.rx.text.orEmpty.bind(to: viewModel.confirmPasswordText)
        viewModel.isValid.map { !$0 }.bind(to: signUpButton.rx.isHidden).disposed(by: bag)
        
        signUpButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                guard let `self` = self,
                    let email = self.emailTextField.text,
                    let password = self.passwordTextField.text else { return }
                self.signUp(email: email, password: password)
            }
        .disposed(by: bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.user
            .subscribe(onNext: { [weak self] (user) in
                self?.performSegue(withIdentifier: Segue.kUpdateUserInfo, sender: user.uid)
            })
            .disposed(by: bag)
    }
    
    private func signUp(email: String, password: String) {
        viewModel.singUp(email: email, password: password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let updateUserInforViewController = segue.destination as? UpdateUserInfoViewController {
            if let userId = sender as? String {
                updateUserInforViewController.userId = userId
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case let tf where tf == emailTextField:
            passwordTextField.becomeFirstResponder()
        case let tf where tf == passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case let tf where tf == confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
        default:
        break
        }
        return true
    }
}
