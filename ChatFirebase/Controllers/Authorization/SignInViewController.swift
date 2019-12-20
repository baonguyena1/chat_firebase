//
//  SignInViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    @IBAction func signUp(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Segue.kSignUp, sender: self)
    }
    
}
