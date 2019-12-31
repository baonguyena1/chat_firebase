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

class SingleChatViewModel {
    
    private let bag = DisposeBag()
    
    private(set) var newConversationId = PublishRelay<String>()
    
    private(set) var sentMessageStatus = PublishRelay<Bool>()
    
    private(set) var initialChatStatus = PublishRelay<Bool>()
    
    private(set) var conversation = PublishRelay<Conversation>()
    
    
    private(set) var chatMessages = BehaviorRelay<[ChatMessage]>(value: [])
    
    private var messages = [Message]()

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
            .flatMap { conversationId in self.createMessages(datas: data, sender: sender, conversationId: conversationId).map { conversationId } }
            .subscribe(onNext: { [weak self] (conversationId) in
                self?.newConversationId.accept(conversationId)
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
                var currentMessages = self.messages
                snapshot.documentChanges.forEach { (change) in
                    let document = change.document
                    var data = document.data()
                    data[KeyPath.kDocumentID] = document.documentID
                    let message = Message(from: data)
                    
                    switch change.type {
                        case .added:
                            currentMessages.append(message)
                        case.modified:
                            if let index = currentMessages.firstIndex(where: { $0.documentID == message.documentID }) {
                                currentMessages[index] = message
                            }
                        case .removed:
                            if let index = currentMessages.firstIndex(where: { $0.documentID == message.documentID }) {
                                currentMessages.remove(at: index)
                            }
                    }
                }
                self.setMessages(messages: currentMessages)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            }, onCompleted: {
                
            })
            .disposed(by: bag)
    }
    
    func message(id: String) -> Message {
        if let message = self.messages.first(where: { $0.documentID == id }) {
            return message
        }
        fatalError()
    }
    
    private func setMessages(messages: [Message]) {
        let list = messages.sorted { (m1, m2) -> Bool in
            m1.createdAt < m2.createdAt
        }
        self.messages = list
        let chatMessages: [ChatMessage] = list.compactMap {
            if $0.messagaType == ChatType.text.rawValue {
                return ChatMessage(text: $0.message, user: sender, messageId: $0.documentID, date: $0.createdAt.date)
            }
            return nil
        }
        self.chatMessages.accept(chatMessages)
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
    
    private func createMessages(datas: [Any], sender: String, conversationId: String) -> Observable<Void> {
        let actions = datas.map {
            self.createMessage(sender: sender, data: $0, conversationId: conversationId)
                .flatMap { self.updateLastMessage(toConversation: conversationId, messageId: $0) }
        }
        return Observable.merge(actions)
    }
    
    /// Create message in conversation
    /// - Parameter data:
    private func createMessage(sender: String, data: Any, conversationId: String) -> Observable<String> {
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
