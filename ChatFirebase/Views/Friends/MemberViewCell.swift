//
//  MemberViewCell.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit

class MemberViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var user: User! {
        didSet {
            setupUI()
        }
    }
    
    private func setupUI() {
        if let avatar = user.avatar {
            avatarImageView.setImage(with: avatar, placeholder: nil)
        }
        displayNameLabel.text = user.displayName
        descriptionLabel.text = user.email
    }
}
