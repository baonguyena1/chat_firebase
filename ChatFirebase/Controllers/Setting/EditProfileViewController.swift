//
//  EditProfileViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/2/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    private let bag = DisposeBag()
    
    private var viewModel: EditProfileViewModel!
    
    private var imagePickerController: ImagePickerController!
    
    private let user = LoginUserManager.shared.user.value

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialViewModel()

        setupUI()
        
        initialReactive()
    }
    
    private func setupUI() {
        avatarImageView.setImage(with: user.avatar ?? "", placeholder: nil)
        nameTextField.text = user.displayName
    }
    
    private func initialViewModel() {
        imagePickerController = ImagePickerController()
        viewModel = EditProfileViewModel()
    }
    
    private func initialReactive() {
        cancelButton.rx.tap
            .subscribe { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: bag)
        
        doneButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                self?.editProfile()
            }
            .disposed(by: bag)
        
        imagePickerController.selectedImage
            .subscribe(onNext: { [weak self] (image) in
                self?.avatarImageView.image = image
            })
            .disposed(by: imagePickerController.bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.editProfileSuccess
            .subscribe { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: bag)
    }

    @IBAction func viewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func avatarTapped(_ sender: Any) {
        imagePickerController.showPicker(inController: self)
    }
    
    private func editProfile() {
        let image = avatarImageView.image!
        let name = nameTextField.text == user.displayName ? nil : nameTextField.text
        viewModel.edit(image, name: name, previousImageUrl: user.avatar ?? "")
    }
    
}
