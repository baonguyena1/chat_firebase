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
    
    @IBOutlet weak var nameTextField: UITextField!
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
        _ = nameTextField.rx.text.compactMap { $0 }.bind(to: viewModel.nameText)
        _ = emailTextField.rx.text.compactMap { $0 }.bind(to: viewModel.emailText)
        _ = passwordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.passwordText)
        _ = confirmPasswordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.confirmPasswordText)
        
        viewModel.isValid
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: bag)
        
        signUpButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                guard let `self` = self,
                    let email = self.emailTextField.text,
                    let password = self.passwordTextField.text,
                    let name = self.nameTextField.text else { return }
                self.signUp(email: email, password: password, name: name)
            }
        .disposed(by: bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
    }
    
    private func signUp(email: String, password: String, name: String) {
        viewModel.singUp(email: email, password: password, name: name)
    }
}
