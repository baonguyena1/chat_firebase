//
//  Conversation.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/30/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

class Conversation: FireBaseModel {
    var members: [String]!
    var users: [User]!
    var activeMembers: [String]!
    var admins: [String]!
    var lastMessageId: String!
    var lastMessage: Message!
    var name: String!
    var avatar: String!
    
    var displayName: String {
        let currentUserId = FireBaseManager.shared.auth.currentUser?.uid
        if name.isEmpty {
            return activeUsers.filter { $0.documentID != currentUserId }.compactMap { $0.displayName }.joined(separator: ", ")
        }
        return name
    }
    
    var groupAvatar: [String] {
        if !avatar.isEmpty {
            return [avatar]
        }
        let currentUserId = FireBaseManager.shared.auth.currentUser?.uid
        return activeUsers.filter { $0.documentID != currentUserId }.compactMap { $0.avatar }
    }
    
    var activeUsers: [User] {
        return self.users.filter { activeMembers.contains($0.documentID) }
    }
    
    required init(from json: JSON) {
        if let members = json[KeyPath.kMembers] as? [String] {
            self.members = members
        } else {
            self.members = []
        }
        
        if let activeMembers = json[KeyPath.kActiveMembers] as? [String] {
            self.activeMembers = activeMembers
        } else {
            self.activeMembers = []
        }
        
        if let lastMessageId = json[KeyPath.kLastMessageId] as? String {
            self.lastMessageId = lastMessageId
        } else {
            self.lastMessageId = ""
        }
        
        if let name = json[KeyPath.kName] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        
        if let avatar = json[KeyPath.kAvatar] as? String {
            self.avatar = avatar
        } else {
            self.avatar = ""
        }
        if let admins = json[KeyPath.kAdmins] as? [String] {
            self.admins = admins
        } else {
            self.admins = []
        }
        super.init(from: json)
    }
}
