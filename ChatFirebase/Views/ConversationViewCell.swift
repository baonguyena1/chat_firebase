//
//  ConversationViewCell.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/30/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit

class ConversationViewCell: UITableViewCell {
    
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

    var conversation: Conversation! {
        didSet {
            setupUI()
        }
    }
    
    private func setupUI() {
        avatarImageView.setImage(with: conversation.avatar, placeholder: nil)
        displayNameLabel.text = conversation.displayName
        descriptionLabel.text = conversation.lastMessage.message
    }
}
