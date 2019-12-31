//
//  Message.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/31/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

class Message: FireBaseModel {
    var message: String!
    var messagaType: String!
    var sender: String!
    
    required init(from json: JSON) {
        if let message = json[KeyPath.kMessage] as? String {
            self.message = message
        } else {
            self.message = ""
        }
        
        if let messagaType = json[KeyPath.kMessageType] as? String {
            self.messagaType = messagaType
        } else {
            self.messagaType = ""
        }
        
        if let sender = json[KeyPath.kSender] as? String {
            self.sender = sender
        } else {
            self.sender = ""
        }
        super.init(from: json)
    }
}
