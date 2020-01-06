//
//  AddPeopleViewCell.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/6/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class AddPeopleViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    public private(set) var bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        bag = DisposeBag()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
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
