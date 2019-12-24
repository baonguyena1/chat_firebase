//
//  UIImageView+Helper.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String, placeholder: UIImage? = #imageLiteral(resourceName: "ic_user.png")) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: URL(string: urlString), placeholder: placeholder)
    }
}
