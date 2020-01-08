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
import FirebaseFunctions
import RxFirebase
import RxSwift

class FireBaseManager {
    
    static let shared = FireBaseManager()
    
    // MARK: -  Properties
    
    lazy var auth: Auth = {
        return Auth.auth()
    }()
    
    lazy var firestore: Firestore = {
        return Firestore.firestore()
    }()
    
    lazy var storage: Storage = {
        return Storage.storage()
    }()
    
    lazy var function: Functions = {
        return Functions.functions()
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
        return storage.reference().child(FireBaseName.kUserProfiles)
    }()
    
    lazy var chatAvatarStorage = {
        return storage.reference().child(FireBaseName.kChats)
    }()
    
    // MARK: - Common function
    
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
                        if !snapshot.exists {
                            return .just(nil)
                        }
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
    
    func offlineCloudFireStore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        self.firestore.settings = settings
    }
    
    func uploadAndGetImageURL(_ image: UIImage, reference: StorageReference) -> Observable<String> {
        return uploadImage(image, ref: reference)
            .flatMapLatest { (status) -> Observable<String> in
                if status {
                    return self.getUrl(reference: reference)
                } else {
                    return Observable.just("")
                }
        }
    }
    
    func uploadGetDelete(_ image: UIImage, previousLink: String, reference: StorageReference) -> Observable<String> {
        return uploadImage(image, ref: reference)
            .flatMap { (success) -> Observable<String> in
                if !success {
                    return .just("")
                }
                return Observable.zip(self.getUrl(reference: reference),
                                      self.deleteImage(urlString: previousLink))
                    .compactMap { (url, _) -> String in
                        return url
                }
        }
    }
    
    private func uploadImage(_ image: UIImage, ref: StorageReference) -> Observable<Bool> {
        guard let imageData = image.pngData() else {
            return .just(false)
        }
        return ref.rx.putData(imageData)
            .map { _ in true }
    }
    
    private func getUrl(reference: StorageReference) -> Observable<String> {
        return reference.rx
            .downloadURL()
            .map { $0.absoluteString }
    }
    
    func deleteImage(urlString: String) -> Observable<Void> {
        let validUrl = URL(string: urlString)
        if validUrl == nil {
            return .just(())
        }
        return storage
            .reference(forURL: urlString)
            .rx.delete()
            .catchErrorJustReturn(())
    }
    // MARK: -  Private function
    
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
