//
//  ApplicationNavigator.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit

class ApplicationNavigator {
    static let shared = ApplicationNavigator()
    
    private weak var window: UIWindow?
    
    func setWindow(window: UIWindow?) {
        self.window = window
    }
    
    func checkIfUserIsSignedIn() {
        assert(window != nil)
        let auth = FireBaseManager.shared.auth
        if auth.currentUser == nil {
            showAuthorization()
        } else {
            showMainTabBar()
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
