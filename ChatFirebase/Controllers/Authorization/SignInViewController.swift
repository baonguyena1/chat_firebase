//
//  SignInViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var viewModel: SignInViewModel!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialViewModel()
        
        initialReactive()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func signUp(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Segue.kSignUp, sender: self)
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func initialViewModel() {
        viewModel = SignInViewModel()
    }
    
    private func initialReactive() {
        _ = emailTextField.rx.text.orEmpty.bind(to: viewModel.emailSubject)
        _ = passwordTextField.rx.text.orEmpty.bind(to: viewModel.passwordSubject)
        viewModel.isValid.map { !$0 }.bind(to: signInButton.rx.isHidden).disposed(by: bag)
        
        signInButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                guard let email = self?.emailTextField.text,
                    let password = self?.passwordTextField.text else { return }
                self?.signIn(email: email, password: password)
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
    
    private func signIn(email: String, password: String) {
        viewModel.signIn(email: email, password: password)
    }
}
