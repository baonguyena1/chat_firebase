//
//  Reactive+Helper.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/23/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

extension Reactive where Base: UIView {
    public var isShowHUD: Binder<Bool> {
        return Binder<Bool>.init(base.self, scheduler: MainScheduler.instance) { (view, isLoading) in
            if isLoading {
                MBProgressHUD.showAdded(to: view, animated: true)
            } else {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }
}

extension UIViewController {
    func showError(title: String = "OK", message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
