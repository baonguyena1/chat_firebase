//
//  GroupInfoViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/6/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import MessageKit
import ActiveLabel
import RxSwift
import RxCocoa

class GroupInfoViewController: UIViewController {
    
    @IBOutlet weak var avatarTitleStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leaveGroupLabel: UILabel!
    
    var conversation: Conversation!
    
    private let bag = DisposeBag()
    
    private let viewModel = GroupInfoViewModel()
    
    private var imagePickerController: ImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUI()
        
        setupUI()
        
        initialReactive()
        
        observeConversation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nagivationController = segue.destination as? UINavigationController {
            if let addPeopleController = nagivationController.viewControllers.first as? AddPeopleViewController {
                addPeopleController.conversation = self.conversation
            }
        } else if let memberController = segue.destination as? GroupMemberViewController {
            memberController.members = self.conversation.activeUsers
        }
    }
    
    private func initialUI() {
        avatarTitleStackView.isUserInteractionEnabled = true
        avatarTitleStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:))))
        imagePickerController = ImagePickerController()
    }
    
    private func setupUI() {
        avatarTitleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let users = conversation.activeUsers
        if users.count >= 3 {
            avatarTitleStackView.addArrangedSubview(buildCircleImageView(imageUrl: users[0].avatar ?? ""))
            avatarTitleStackView.addArrangedSubview(buildCircleImageView(imageUrl: users[1].avatar ?? ""))
            
            let title = "\(users.count - 2)+"
            avatarTitleStackView.addArrangedSubview(buildAvatarView(title: title))
        } else {
            for user in users {
                avatarTitleStackView.addArrangedSubview(buildCircleImageView(imageUrl: user.avatar ?? ""))
            }
        }
        titleLabel.text = conversation.displayName
        leaveGroupLabel.isHidden = users.count < 3
    }
    
    private func observeConversation() {
        viewModel.observeConversation(conversationId: conversation.documentID)
    }
    
    private func buildCircleImageView(imageUrl: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.setImage(with: imageUrl, placeholder: nil)
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.cornerRadius = 30
        imageView.borderWidth = 2
        imageView.borderColor = ColorAssets.primaryColor
        return imageView
    }
    
    private func buildAvatarView(title: String) -> UIImageView {
        let avatarView = AvatarView()
        avatarView.backgroundColor = .white
        avatarView.setCorner(radius: 30)
        avatarView.placeholderFont = UIFont.systemFont(ofSize: 23.0, weight: .medium)
        avatarView.placeholderTextColor = .black
        avatarView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        avatarView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor).isActive = true
        avatarView.initials = title
        avatarView.borderWidth = 2
        avatarView.borderColor = ColorAssets.primaryColor
        return avatarView
    }
    
    private func initialReactive() {
        viewModel.conversation
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (conversation) in
                self?.conversation = conversation
                self?.setupUI()
            })
            .disposed(by: bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.leaveGroup
            .subscribe { [weak self] (_) in
                self?.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: bag)
        
        imagePickerController.selectedImage
            .subscribe(onNext: { [weak self] (image) in
                guard let `self` = self else { return }
                self.viewModel.changeGroupPhoto(image: image, previousLink: self.conversation.avatar, conversation: self.conversation.documentID)
            })
            .disposed(by: bag)
    }
    
    @objc
    private func avatarTapped(_ gesture: UITapGestureRecognizer) {
        if conversation.activeMembers.count <= 2 {
            return
        }
        showEditAlert()
    }

    private func showEditAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let changeName = UIAlertAction(title: Localizable.kChangeName, style: .default) { [weak self] (action) in
            self?.showChangeNameAlert()
        }
        alertController.addAction(changeName)
        
        let changeAvatar = UIAlertAction(title: Localizable.kChangeChatPhoto, style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.imagePickerController.showPicker(inController: self)
        }
        alertController.addAction(changeAvatar)
        
        if !conversation.avatar.isEmpty {
            let removeAvatar = UIAlertAction(title: Localizable.kRemoveChatPhoto, style: .default) { [weak self] (action) in
                guard let `self` = self else { return }
                self.viewModel.removePhoto(self.conversation.avatar, conversation: self.conversation.documentID)
            }
            alertController.addAction(removeAvatar)
        }
        
        let cancel = UIAlertAction(title: Localizable.kCancel, style: .destructive)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showChangeNameAlert() {
        let alertController = UIAlertController(title: Localizable.kChangeName, message: nil, preferredStyle: .alert)
        alertController.addTextField { [weak self] (textField) in
            textField.placeholder = Localizable.kChangeName
            textField.text = self?.conversation.displayName
        }
        
        let cancelAction = UIAlertAction(title: Localizable.kCancel, style: .cancel)
        alertController.addAction(cancelAction)
        
        let doneAction = UIAlertAction(title: Localizable.kDone, style: .default) { [weak self] (action) in
            if let name = alertController.textFields?.first?.text, !name.isEmpty,
                let conversationId = self?.conversation.documentID {
                self?.viewModel.changeGroupName(name: name, conversation: conversationId)
            }
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func leaveGroupTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: Localizable.kAreYouSureWantToLeaveYourGroup, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.kCancel, style: .cancel)
        alert.addAction(cancel)
        
        let ok = UIAlertAction(title: Localizable.kOk, style: .destructive) { [weak self] (action) in
            self?.leaveGroup()
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func leaveGroup() {
        guard let userId = LoginUserManager.shared.user.value.documentID, !userId.isEmpty,
            let conversationId = conversation.documentID else { return }
        viewModel.leaveGroup(user: userId, conversation: conversationId)
    }
}
