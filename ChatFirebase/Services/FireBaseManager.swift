//
//  FirebaseManager.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/23/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FireBaseManager {
    
    static let shared = FireBaseManager()
    
    lazy var auth: Auth = {
        return Auth.auth()
    }()
    
    lazy var firestore: Firestore = {
        return Firestore.firestore()
    }()
    
    lazy var usersCollection: CollectionReference = {
        return firestore.collection("users")
    }()
    
    lazy var userProfileStorage = {
        return Storage.storage().reference().child("user_profiles")
    }()
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let error {
            Logger.log(error.localizedDescription)
        }
    }
}
