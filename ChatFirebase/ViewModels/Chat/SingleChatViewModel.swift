//
//  SingleChatViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/31/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
import MessageKit

//enum MessageChange {
//    case added(message: [Message])
//    case modified(message: Message)
//    case removed (message: Message)
//}

class SingleChatViewModel {
    
    private let bag = DisposeBag()
    
    private(set) var conversationId = PublishRelay<String>()
    
    private(set) var sentMessageStatus = PublishRelay<Bool>()
    
    private(set) var initialChatStatus = PublishRelay<Bool>()
    
    private(set) var conversation = PublishRelay<Conversation>()
    
//    private(set) var messagesChange = PublishRelay<MessageChange>()
    
    private(set) var messages = BehaviorRelay<[Message]>(value: [])

    private var sender: SenderUser
    
    init(sender: SenderUser) {
        self.sender = sender
    }
    
    func initialConversation(members: [String], sender: String, data: [Any]) {
        self.sentMessageStatus.accept(true)
        createConversation(data: [
                KeyPath.kMembers: members,
                KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
                KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970
            ])
            .flatMap { conversationId in self.createUserChat(listUser: members, conversationId: conversationId).map { conversationId } }
            .flatMap { conversationId in self.createMessages(sender: sender, conversation: conversationId, data: data).map { conversationId } }
            .subscribe(onNext: { [weak self] (conversationId) in
                self?.conversationId.accept(conversationId)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: { [weak self] in
                self?.sentMessageStatus.accept(false)
            })
            .disposed(by: bag)
    }
    
    func observeConversation(conversationId: String) {
        FireBaseManager.shared.observeConversation(conversation: conversationId)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] (conversation) in
                self?.conversation.accept(conversation)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: {
                
            })
        .disposed(by: bag)
    }
    
    func observeMessages(inConversation id: String) {
        let messagesCollection = FireBaseManager.shared.messagesCollection(conversation: id)
        messagesCollection.rx
            .listen()
            .subscribe(onNext: { [weak self] (snapshot) in
                
                guard let `self` = self else { return }
                var currentMessages = self.messages.value

                snapshot.documentChanges.forEach { (change) in
                    let document = change.document
                    var data = document.data()
                    data[KeyPath.kDocumentID] = document.documentID
                    let message = Message(from: data)

                    switch change.type {
                        case .added:
                            currentMessages.append(message)
                            currentMessages.sort { (m1, m2) -> Bool in
                                return m1.createdAt < m2.createdAt
                            }
                        case .modified:
                            if let index = currentMessages.firstIndex(where: { $0.documentID == message.documentID }) {
                                currentMessages[index] = message
                            }
                        case .removed:
                            if let index = currentMessages.firstIndex(where: { $0.documentID == message.documentID }) {
                                currentMessages.remove(at: index)
                            }
                    }
                }
                
                self.messages.accept(currentMessages)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: {
                
            })
            .disposed(by: bag)
    }
    
    func getHistoryLog(sender: String, receiver: String) {
        let senderChatRef = FireBaseManager.shared.userChatsCollection.document(sender)
        let receiertChatRef = FireBaseManager.shared.userChatsCollection.document(receiver)
        Observable.zip(FireBaseManager.shared.documentExists(docRef: senderChatRef),
                       FireBaseManager.shared.documentExists(docRef: receiertChatRef))
            .flatMap { (doc1, doc2) -> Observable<[String]> in
                if doc1 && doc2 {
                    return Observable.zip(self.getConversationUserChat(docRef: senderChatRef),
                                          self.getConversationUserChat(docRef: receiertChatRef))
                        .flatMap { (arg) -> Observable<[String]> in
                            
                            let (r1, r2) = arg
                            return .just(Array(r1.intersection(r2)))
                    }
                }
                return .just([])
            }
            .flatMap { (listConversation) -> Observable<String?> in
                return self.findConversationBetween(sender: sender, receiver: receiver, inList: listConversation)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] (conversationId) in
                Logger.log("\(conversationId)")
                self?.conversationId.accept(conversationId)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func createNewMessages(sender: String, conversation: String, data: [Any]) {
        createMessages(sender: sender, conversation: conversation, data: data)
            .subscribe(onNext: { (_) in
                Logger.log("")
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    // Find conversation between two user
    private func getConversationUserChat(docRef: DocumentReference) -> Observable<Set<String>> {
        FireBaseManager.shared.getDocument(docRef: docRef)
            .compactMap { (snapshot) -> Set<String> in
                var results = Set<String>()
                if let data = snapshot.data(), let conversations = data[KeyPath.kConversations] as? [String] {
                    results = Set(conversations)
                }
                return results
            }
    }
    
    private func findConversationBetween(sender: String, receiver: String, inList list: [String]) -> Observable<String?> {
        let conversations = list.map { (docId) -> Observable<DocumentSnapshot> in
            let docRef = FireBaseManager.shared.conversationsCollection.document(docId)
            return FireBaseManager.shared.getDocument(docRef: docRef)
        }
        return Observable.zip(conversations)
            .flatMap { (snapshots) -> Observable<String?> in
                for snapshot in snapshots where snapshot.data() != nil {
                    let data = snapshot.data()!
                    if let members = data[KeyPath.kMembers] as? [String], members.count == 2, members.contains(sender), members.contains(receiver) {
                        return .just(snapshot.documentID)
                    }
                }
                return .just(nil)
        }
    }
    
    /// Create new conversation, return the conversation ID
    /// - Parameter data: Contents
    private func createConversation(data: [String: Any]) -> Observable<String> {
        let conversation = FireBaseManager.shared.conversationsCollection
        return conversation.rx.addDocument(data: data)
            .flatMap { Observable.just($0.documentID) }
    }
    
    /// Create the User Chat Log
    /// - Parameters:
    ///   - listUser: user in the conversation
    ///   - conversationId: conversation id
    private func createUserChat(listUser: [String], conversationId: String) -> Observable<Void> {
        let chatLogs = listUser.map { self.createUserChatLog(userId: $0, conversationId: conversationId) }
        return Observable.zip(chatLogs)
            .flatMap { _ in Observable.just(()) }
    }
    
    private func createUserChatLog(userId: String, conversationId: String) -> Observable<Void> {
        let userChatRef = FireBaseManager.shared.userChatsCollection.document(userId)
        return FireBaseManager.shared.documentExists(docRef: userChatRef)
            .flatMap { exists -> Observable<Void> in
                if exists {
                    return userChatRef.rx.updateData([KeyPath.kConversations: FieldValue.arrayUnion([conversationId])])
                }
                return userChatRef.rx.setData([KeyPath.kConversations: [conversationId]])
            }
    }
    
    private func createMessages(sender: String, conversation: String, data: [Any]) -> Observable<Void> {
        let actions = data.map {
            self.createMessage(sender: sender, conversationId: conversation, data: $0)
                .flatMap { self.updateLastMessage(toConversation: conversation, messageId: $0) }
        }
        return Observable.merge(actions)
    }
    
    /// Create message in conversation
    /// - Parameter data:
    private func createMessage(sender: String, conversationId: String, data: Any) -> Observable<String> {
        let messages = FireBaseManager.shared.messagesCollection(conversation: conversationId)
        if let str = data as? String {
            let content: [String: Any] = [
                KeyPath.kSenderId: sender,
                KeyPath.kMessage: str,
                KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
                KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
                KeyPath.kMessageType: ChatType.text.rawValue
            ]
            return messages.rx.addDocument(data: content)
                .flatMap { Observable.just($0.documentID) }
        }
        return Observable.just("")
    }
    
    private func updateLastMessage(toConversation conversationId: String, messageId: String) -> Observable<Void> {
        let conversation = FireBaseManager.shared.conversationsCollection.document(conversationId)
        let data = [
            KeyPath.kLastMessageId: messageId
        ]
        return conversation.rx.updateData(data)
    }
    
    
}
