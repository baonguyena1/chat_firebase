//
//  UpdateUserInfoViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/24/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class UpdateUserInfoViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var viewModel: UpdateUserInforViewModel!
    
    var userId: String!
    
    private let bag = DisposeBag()
    private var imagePickerController: ImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(userId != nil)
        
        initialViewModel()
        
        initialReactive()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func chooseImageTapped(_ sender: UITapGestureRecognizer) {
        imagePickerController.showPicker(inController: self)
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func initialViewModel() {
        imagePickerController = ImagePickerController()
        viewModel = UpdateUserInforViewModel()
    }
    
    private func initialReactive() {
        nameTextField.rx.text.orEmpty.bind(to: viewModel.nameSubject).disposed(by: bag)
        viewModel.isValid.map { !$0 }.bind(to: doneButton.rx.isHidden).disposed(by: bag)
        
        imagePickerController.selectedImage
            .subscribe(onNext: { [weak self] (image) in
                self?.chooseImage(image)
            })
            .disposed(by: imagePickerController.bag)
        
        viewModel.rx_isLoading.bind(to: self.view.rx.isShowHUD)
            .disposed(by: bag)
        
        viewModel.rx_error
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(message: error)
            })
            .disposed(by: bag)
        
        viewModel.updatedInfoStatus
            .subscribe { (_) in
                ApplicationNavigator.shared.showMainTabBar()
            }
            .disposed(by: bag)
        
        doneButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] (_) in
                guard let `self` = self,
                    let image = self.avatarImageView.image,
                    let name = self.nameTextField.text,
                    let email = FireBaseManager.shared.auth.currentUser?.email else { return }
                self.viewModel.updateUserInfo(userId: self.userId, image: image, name: name, email: email)
            }
            .disposed(by: bag)
    }
    
    private func chooseImage(_ image: UIImage) {
        self.avatarImageView.image = image
        viewModel.chooseAvatarSubject.onNext(true)
    }
}
