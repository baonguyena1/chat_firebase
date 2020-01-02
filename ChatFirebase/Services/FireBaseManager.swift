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
import RxFirebase
import RxSwift

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
        return FireBaseManager.shared.roomsCollection.document(conversation).collection(FireBaseName.kMessages)
    }
    
    func messageDocument(inConversation conversation: String, messageId: String) -> DocumentReference {
        return messagesCollection(conversation: conversation).document(messageId)
    }
    
    func documentExists(docRef: DocumentReference) -> Observable<Bool> {
        getDocument(docRef: docRef)
            .flatMap { Observable.just($0.exists) }
            .catchErrorJustReturn(false)
    }
    
    func getDocument(docRef: DocumentReference) -> Observable<DocumentSnapshot> {
        return docRef.rx.getDocument()
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let error {
            Logger.log(error.localizedDescription)
        }
    }
    
    func observeConversation(conversation: String) -> Observable<Conversation?> {
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        return FireBaseManager.shared.documentExists(docRef: conversationRef)
            .flatMap { (exists) -> Observable<Conversation?> in
                if !exists {
                    return .just(nil)
                }
                return conversationRef.rx
                    .listen()
                    .flatMapLatest{ [weak self] (snapshot) -> Observable<Conversation?> in
                        
                        guard let `self` = self, var data = snapshot.data() else {
                            return  Observable.just(nil)
                        }
                        data[KeyPath.kDocumentID] = snapshot.documentID
                        let conversation = Conversation(from: data)
                        if conversation.members.isEmpty || conversation.lastMessageId.isEmpty {
                            return .just(nil)
                        }
                        let users = self.getUsers(listUser: conversation.members)
                        let message = self.getMessage(messageId: conversation.lastMessageId, conversation: conversation.documentID)
                        return Observable.zip(users, message)
                            .flatMap { (arg) -> Observable<Conversation?> in
                                
                                let (users, message) = arg
                                conversation.users = users
                                conversation.lastMessage = message
                                return Observable.just(conversation)
                        }
                }
        }
        
    }
    
    private func getUsers(listUser: [String]) -> Observable<[User]> {
        let users = listUser.compactMap { self.getUser(userId: $0) }
        return Observable.zip(users)
    }
    
    private func getUser(userId: String) -> Observable<User> {
        return FireBaseManager.shared.usersCollection.document(userId).rx
            .getDocument()
            .compactMap { (snapshot) -> User? in
                if var data = snapshot.data() {
                    data[KeyPath.kDocumentID] = snapshot.documentID
                    return User(from: data)
                }
                return nil
        }
    }
    
    private func getMessage(messageId: String, conversation: String) -> Observable<Message> {
        return FireBaseManager.shared.messageDocument(inConversation: conversation, messageId: messageId).rx
            .getDocument()
            .compactMap { (snapshot) -> Message? in
                if var data = snapshot.data() {
                    data[KeyPath.kDocumentID] = snapshot.documentID
                    return Message(from: data)
                }
                return nil
        }
    }
    
}
