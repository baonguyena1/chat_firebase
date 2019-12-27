//
//  SenderUser.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/27/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import MessageKit

struct SenderUser: SenderType, Equatable {
    var senderId: String 
    
    var displayName: String

    static func == (lhs: SenderUser, rhs: SenderUser) -> Bool {
        lhs.senderId == rhs.senderId
    }
}
