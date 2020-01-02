//
//  Enums.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit

enum StoryboardName: String {
    case Main
    case Authorization
    case Friend
    case Setting
    case Conversation
    case Chat
}

enum ChatType: String {
    case text = "TEXT"
}

enum ChatAccession {
    case history(conversationId: String)
    case friend(friendId: String)
}

enum ColorAssets {
    static let borderColor = UIColor(named: "BorderColor")!
    static let grayColor = UIColor(named: "GrayColor")!
    static let linkColor = UIColor(named: "LinkColor")!
    static let primaryColor = UIColor(named: "PrimaryColor")!
    static let seperatorColor = UIColor(named: "SeparatorColor")!
}

enum ImageAssets {
    static let girl_phone = UIImage(named: "girl_phone")
    static let ic_member = UIImage(named: "ic_member")
    static let ic_up = UIImage(named: "ic_up")
    static let placeholder_message_empty = UIImage(named: "placeholder_message_empty")
    static let ic_sign_out = UIImage(named: "ic_sign_out")
    static let empty_photo = UIImage(named: "empty_photo")
    static let ic_user = UIImage(named: "ic_user")
    static let member = UIImage(named: "member")
    static let ic_member_tabbar = UIImage(named: "ic_member_tabbar")
    static let ic_message_tabbar = UIImage(named: "ic_message_tabbar")
    static let ic_user_tabbar = UIImage(named: "ic_user_tabbar")
}
