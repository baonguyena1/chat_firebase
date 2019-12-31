//
//  User.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

class User: Codable {
    var documentID: String!
    var avatar: String?
    var displayName: String?
    var email: String?
    var createdAt: Double!
    var updatedAt: Double!
    
    init(from json: JSON) {
        self.avatar = json[KeyPath.kAvatar] as? String
        self.displayName = json[KeyPath.kDisplayName] as? String
        self.documentID = (json[KeyPath.kDocumentID] as? String) ?? ""
        self.email = json[KeyPath.kEmail] as? String
        self.createdAt = (json[KeyPath.kCreatedAt] as? Double) ?? Date().milisecondTimeIntervalSince1970
        self.updatedAt = (json[KeyPath.kCreatedAt] as? Double) ?? Date().milisecondTimeIntervalSince1970
    }
}
