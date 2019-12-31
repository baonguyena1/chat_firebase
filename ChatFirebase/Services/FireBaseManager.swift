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
        return firestore.collection(FireBaseName.kUsers)
    }()
    
    lazy var conversationsCollection: CollectionReference = {
        return firestore.collection(FireBaseName.kConversations)
    }()
    
    lazy var roomsCollection: CollectionReference = {
        return firestore.collection(FireBaseName.kRooms)
    }()
    
    lazy var userChatsCollection: CollectionReference = {
        return firestore.collection(FireBaseName.kUserChats)
    }()
    
    lazy var userProfileStorage = {
        return Storage.storage().reference().child(FireBaseName.kUserProfiles)
    }()
    
    func messagesCollection(conversation: String) -> CollectionReference {
        FireBaseManager.shared.roomsCollection.document(conversation).collection(FireBaseName.kMessages)
    }
    
    func messageDocument(inConversation conversation: String, messageId: String) -> DocumentReference {
        return messagesCollection(conversation: conversation).document(messageId)
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let error {
            Logger.log(error.localizedDescription)
        }
    }
}
