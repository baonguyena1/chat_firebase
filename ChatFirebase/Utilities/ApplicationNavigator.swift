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
    
    func checkIfUserIsSignedIn() {
        let auth = FireBaseManager.shared.auth
        FireBaseManager.shared.signOut()
        if auth.currentUser == nil {
            showAuthorization()
        } else {
            showMainTabBar()
        }
        auth.addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                self?.showAuthorization()
            } else {
                self?.showMainTabBar()
            }
        }
    }
    
    func showAuthorization() {
        let signInViewController = SignInViewController.instantiate(name: StoryboardName.Authorization.rawValue)
        let navigationController = UINavigationController(rootViewController: signInViewController)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func showMainTabBar() {
        let mainTabBarViewController = MainTabBarViewController.instantiate(name: StoryboardName.Main.rawValue)
        window?.rootViewController = mainTabBarViewController
        window?.makeKeyAndVisible()
    }
}
