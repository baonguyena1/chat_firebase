//
//  SignInViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import ActiveLabel

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpLabel: ActiveLabel!
    
    var viewModel: SignInViewModel!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        initialViewModel()
        
        initialReactive()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func setupUI() {
        let customType = ActiveType.custom(pattern: "\\sSign Up\\b")
        signUpLabel.customize { (label) in
            
            label.textColor = .lightGray
            label.text = Localizable.kDontHaveAccountSignUp
            label.enabledTypes = [customType]
            label.configureLinkAttribute = { type, attribute, isSelected in
                var atts = attribute
                switch type {
                    case customType:
                        atts[.font] = UIFont.systemFont(ofSize: 15, weight: .medium)
                        atts[.foregroundColor] = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                    default:
                    break
                }
                return atts
            }
            label.handleCustomTap(for: customType) { [weak self] (element) in
                self?.performSegue(withIdentifier: Segue.kSignUp, sender: self)
            }
        }
        emailTextField.becomeFirstResponder()
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
        
        viewModel.loginSubject
            .subscribe { (_) in
                ApplicationNavigator.shared.showMainTabBar()
            }
        .disposed(by: bag)
    }
    
    private func signIn(email: String, password: String) {
        viewModel.signIn(email: email, password: password)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
