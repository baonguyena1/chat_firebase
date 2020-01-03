//
//  ChangePasswordViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/3/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let bag = DisposeBag()
    
    private let viewModel = ChangePasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        initialReactive()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        oldPasswordTextField.becomeFirstResponder()
    }
    
    private func initialReactive() {
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.passwordSubject).disposed(by: bag)
        oldPasswordTextField.rx.text.orEmpty.bind(to: viewModel.oldPasswordSubject).disposed(by: bag)
        viewModel.isValid.bind(to: doneButton.rx.isEnabled).disposed(by: bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.changePasswordSuccess
            .subscribe { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: bag)
        
        doneButton.rx.tap
            .subscribe { [weak self] (_) in
                if let password = self?.passwordTextField.text,
                    let oldPass = self?.oldPasswordTextField.text,
                    let userId = FireBaseManager.shared.auth.currentUser?.uid {
                        self?.viewModel.changePassword(oldPass: oldPass, password: password, forUser: userId)
                }
            }
            .disposed(by: bag)
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPasswordTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
