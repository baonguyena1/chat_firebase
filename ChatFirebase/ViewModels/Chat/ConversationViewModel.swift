//
//  ConversationViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/30/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ConversationViewModel {
    
    private let bag = DisposeBag()
    
    private(set) var conversations = BehaviorRelay<[Conversation]>(value: [])
    
    func observeUserChatConversation(userId: String) {
        let userChatConversation = FireBaseManager.shared.userChatsCollection.document(userId)
        userChatConversation.rx
            .listen()
            .flatMapLatest { [weak self] (snapshot) -> Observable<Conversation?> in
                guard let data = snapshot.data(),
                    let conversations = data[KeyPath.kConversations] as? [String] else {
                        return Observable.just(nil)
                }
                let conversationsObservable = conversations.compactMap { self?.observeConversation(conversation: $0) }
                return Observable.merge(conversationsObservable)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] (conversation) in
                self?.addConversation(conversation: conversation)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    private func observeConversation(conversation: String) -> Observable<Conversation?> {
        return FireBaseManager.shared.conversationsCollection.document(conversation).rx
            .listen()
            .flatMapLatest{ [weak self] (snapshot) -> Observable<Conversation?> in
                
                guard let `self` = self, var data = snapshot.data() else {
                    return  Observable.just(nil)
                }
                data[KeyPath.kDocumentID] = snapshot.documentID
                let conversation = Conversation(from: data)
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
    
    private func addConversation(conversation: Conversation) {
        var conversations = self.conversations.value
        if let index = conversations.firstIndex(where: { $0.documentID == conversation.documentID }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
        conversations.sort { (c1, c2) -> Bool in
            return c1.updatedAt < c2.updatedAt
        }
        self.conversations.accept(conversations)
    }
    
}
