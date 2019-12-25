//
//  SettingViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift

class SettingViewController: UIViewController {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var signoutView: UIView!
    
    private let bag = DisposeBag()
    private let viewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        observeProfile()
        
        initialReactive()
    }
    
    private func observeProfile() {
        guard let userId = FireBaseManager.shared.auth.currentUser?.uid else {
            return
        }
        viewModel.observeProfile(userId: userId)
    }

    private func setupUI() {
        signoutView.rx.tapGesture()
            .when(.recognized)
            .subscribe { [weak self] (_) in
                self?.showSignOutWarning()
            }
        .disposed(by: bag)
    }
    
    private func initialReactive() {
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.signOutEvent
            .subscribe { (_) in
                ApplicationNavigator.shared.showAuthorization()
        }
        .disposed(by: bag)
        
        viewModel.profile
            .subscribe(onNext: { [weak self] (profile) in
                DispatchQueue.main.async {
                    self?.showProfileInfo(profile)
                }
            })
            .disposed(by: bag)
    }
    
    private func showProfileInfo(_ profile: Member) {
        if let avatar = profile.avatar {
            userAvatarImageView.setImage(with: avatar)            
        }
        displayNameLabel.text = profile.displayName
    }
    
    private func showSignOutWarning() {
        let alertController = UIAlertController(title: nil, message: Localizable.kAreYouSureWantToSignOut, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Localizable.kYes, style: .default, handler: { [weak self] action in
            self?.viewModel.signOut()
        }))
        alertController.addAction(UIAlertAction(title: Localizable.kNo, style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
