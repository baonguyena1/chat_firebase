//
//  SignUpViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

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

    @IBAction func signUpTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func setupViewModel() {
        viewModel = SignUpViewModel()
        _ = emailTextField.rx.text.compactMap { $0 }.bind(to: viewModel.emailText)
        _ = passwordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.passwordText)
        _ = confirmPasswordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.confirmPasswordText)
        viewModel.isValid
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: bag)
    }
}
