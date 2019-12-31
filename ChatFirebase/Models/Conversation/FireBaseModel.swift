//
//  FireBaseModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/31/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

class FireBaseModel {
    var documentID: String!
    var createdAt: Double!
    var updatedAt: Double
    
    required init(from json: JSON) {
        if let documentID = json[KeyPath.kDocumentID] as? String {
            self.documentID = documentID
        } else {
            self.documentID = ""
        }
        
        self.createdAt = (json[KeyPath.kCreatedAt] as? Double) ?? Date().milisecondTimeIntervalSince1970
        self.updatedAt = (json[KeyPath.kCreatedAt] as? Double) ?? Date().milisecondTimeIntervalSince1970
    }
}
