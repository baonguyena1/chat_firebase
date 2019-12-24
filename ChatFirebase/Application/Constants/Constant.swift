//
//  Constant.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]
typealias JSONArray = [JSON]

struct Segue {
    static let kSignUp = "signUpSegue"
    static let kUpdateUserInfo = "updateUserInfoSegue"
}

struct KeyPath {
    static let kDisplayName = "displayName"
    static let kAvatar = "avatar"
    static let kId = "id"
    static let kEmail = "email"
    static let kCreatedAt = "created_at"
    static let kUpdatedAt = "updated_at"
}

struct ImageAsset {
    static let kPlaceholderMessageEmpty = "placeholder_message_empty"
}

struct Localizable {
    static let kDontHaveAccountSignUp = NSLocalizedString("Don't have account? Sign Up", comment: "")
    static let kNoMessages = "No Messages"
    static let kWhenYouHaveMessagesYoullSeeThemHere = "When you have messages, you'll see them here."
}
