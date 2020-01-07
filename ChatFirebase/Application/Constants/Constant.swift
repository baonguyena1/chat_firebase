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

let kMaximumChatCharactor = 140

struct Segue {
    static let kSignUp = "signUpSegue"
    static let kUpdateUserInfo = "updateUserInfoSegue"
    static let kFriendToSingleChat = "friendToSingleChatSeque"
    static let kConversationToSingleChat = "conversationToSingleChatSegue"
}

struct KeyPath {
    static let kDisplayName = "displayName"
    static let kAvatar = "avatar"
    static let kEmail = "email"
    static let kCreatedAt = "created_at"
    static let kUpdatedAt = "updated_at"
    static let kUid = "uid"
    static let kMembers = "members"
    static let kLastMessageId = "last_message_id"
    static let kLastMessage = "last_message"
    static let kName = "name"
    static let kConversations = "conversations"
    static let kSender = "sender"
    static let kMessage = "message"
    static let kMessageType = "message_type"
    static let kDocumentID = "documentID"
    static let kSenderId = "sender_id"
}

struct Localizable {
    static let kDontHaveAccountSignUp = "Don't have account? Sign Up".localized
    static let kNoMessages = "No Messages".localized
    static let kWhenYouHaveMessagesYoullSeeThemHere = "When you have messages, you'll see them here.".localized
    static let kAreYouSureWantToSignOut = "Are you sure want to Sign Out?".localized
    static let kYes = "Yes".localized
    static let kNo = "No".localized
    static let kSearchConversations = "Search Conversations".localized
    static let kSearchFriends = "Search Friends".localized
    static let kSending = "Sending...".localized
    static let kCancel = "Cancel".localized
    static let kAa = "Aa".localized
    static let kChangeName = "Change Name".localized
    static let kChangeChatPhoto = "Change Chat Photo".localized
    static let kOk = "Ok".localized
    static let kAreYouSureWantToLeaveYourGroup = "Are you sure want to leave your group?".localized
    static let kRemovedUser = "Removed User".localized
}
