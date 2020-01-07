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
            memberController.members = self.conversation.users
        }
    }
    
    private func initialUI() {
        avatarTitleStackView.isUserInteractionEnabled = true
        avatarTitleStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:))))
        imagePickerController = ImagePickerController()
    }
    
    private func setupUI() {
        avatarTitleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let users = conversation.users else { return }
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
        
        imagePickerController.selectedImage
            .subscribe(onNext: { (image) in
                
            })
            .disposed(by: bag)
    }
    
    @objc
    private func avatarTapped(_ gesture: UITapGestureRecognizer) {
        if conversation.users.count <= 2 {
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
        
        let okAction = UIAlertAction(title: Localizable.kOk, style: .default) { [weak self] (action) in
            if let name = alertController.textFields?.first?.text, !name.isEmpty,
                let conversationId = self?.conversation.documentID {
                self?.viewModel.changeGroupName(name: name, conversation: conversationId)
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
