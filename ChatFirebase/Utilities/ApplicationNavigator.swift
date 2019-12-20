//
//  ApplicationNavigator.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit

class ApplicationNavigator {
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    func showAuthorization() {
        let signInViewController = SignInViewController.instantiate(name: StoryboardName.Authorization.rawValue)
        let navigationController = UINavigationController(rootViewController: signInViewController)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
