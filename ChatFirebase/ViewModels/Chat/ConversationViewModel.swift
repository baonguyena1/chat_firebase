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

class ConversationViewModel {
    
    private let bag = DisposeBag()
    
    private(set) var conversationId = PublishRelay<String>()
    
    private(set) var initialChatStatus = PublishRelay<Bool>()
    
    private(set) var conversation = PublishRelay<Conversation?>()
    
    private(set) var messages = BehaviorRelay<[Message]>(value: [])

    private var sender: SenderUser
    
    init(sender: SenderUser) {
        self.sender = sender
    }
    
    func setupNewConversation(members: [String], sender: String, data: [Any]) {
        createConversation(data: [
                KeyPath.kMembers: members,
                KeyPath.kActiveMembers: members,
                KeyPath.kAdmins: [sender],
                KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
                KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970
            ])
            .flatMap { conversationId in self.createMessages(sender: sender, conversation: conversationId, data: data).map { conversationId } }
            .subscribe(onNext: { [weak self] (conversationId) in
                self?.conversationId.accept(conversationId)
            }, onError: { (error) in
                Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func observeConversation(conversationId: String) {
        FireBaseManager.shared.observeConversation(conversation: conversationId)
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
                            if let index = currentMessages.firstIndex(where: { $0.documentID == message.documentID }) {
                                currentMessages[index] = message
                            } else {
                                currentMessages.append(message)                                
                            }
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
    
    func getHistoryLog(members: [String]) {
        let userChatsRef = members.map { FireBaseManager.shared.userChatsCollection.document($0) }
        let documentExists = userChatsRef.map { FireBaseManager.shared.documentExists(docRef: $0) }
        Observable.zip(documentExists)
            .flatMap { (results) -> Observable<[String]> in
                let check = results.reduce(true) { (acc, next) in
                    return acc && next
                }
                if !check {
                    return .just([])
                }
                return self.getConversationUserChat(documents: userChatsRef)
            }
            .flatMap { (listConversation) -> Observable<String?> in
                return self.findConversation(members: members, inList: listConversation)
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
    
    private func getConversationUserChat(documents: [DocumentReference]) -> Observable<[String]> {
        let userChatAllMembers =  documents.map { self.getConversationUserChat(docRef: $0) }
        return Observable.zip(userChatAllMembers)
            .flatMap { (conversations) -> Observable<[String]> in
                var results = [String]()
                if let initial = conversations.first {
                    let data = conversations.reduce(initial, { (acc, next) in
                        acc.intersection(next)
                    })
                    results = Array(data)
                }
                return .just(results)
        }
    }
    
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
    
    private func findConversation(members: [String], inList list: [String]) -> Observable<String?> {
        let conversations = list.map { (docId) -> Observable<DocumentSnapshot> in
            let docRef = FireBaseManager.shared.conversationsCollection.document(docId)
            return FireBaseManager.shared.getDocument(docRef: docRef)
        }
        return Observable.zip(conversations)
            .flatMap { (snapshots) -> Observable<String?> in
                for snapshot in snapshots where snapshot.data() != nil {
                    let data = snapshot.data()!
                    if let memberList = data[KeyPath.kMembers] as? [String], Set(memberList) == Set(members) {
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
    
    private func createMessages(sender: String, conversation: String, data: [Any]) -> Observable<Void> {
        let actions = data.compactMap { value -> Observable<Void>? in
            if let str = value as? String {
                return self.createTextMessage(sender: sender, conversation: conversation, data: str)
                    .flatMap { _ in Observable.just(()) }
            } else if let image = value as? UIImage {
                return createImageMessage(sender: sender, conversation: conversation, data: image)
                    .flatMap { _ in Observable.just(()) }
            }
            return nil
        }
        return Observable.concat(actions)
    }
    private func createTextMessage(sender: String, conversation: String, data: String) -> Observable<String> {
        let content: [String: Any] = [
            KeyPath.kSenderId: sender,
            KeyPath.kMessage: data,
            KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kMessageType: ChatType.text.rawValue
        ]
        return createMessage(content: content, conversation: conversation)
    }
    
    private func createMessage(content: JSON, conversation: String) -> Observable<String> {
        let messages = FireBaseManager.shared.messagesCollection(conversation: conversation)
        return messages.rx.addDocument(data: content)
            .flatMap { Observable.just($0.documentID) }
    }
    
    private func createImageMessage(sender: String, conversation: String, data: UIImage) -> Observable<String> {
        let imageName = UUID().uuidString.lowercased()
        let imageRef = FireBaseManager.shared.chatConversationStorage.child(conversation).child(sender).child(imageName + ".png")
        return FireBaseManager.shared
            .uploadAndGetImageURL(data, reference: imageRef)
            .flatMap { (url) -> Observable<String> in
                let content: [String: Any] = [
                    KeyPath.kSenderId: sender,
                    KeyPath.kPhoto: url,
                    KeyPath.kCreatedAt: Date().milisecondTimeIntervalSince1970,
                    KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
                    KeyPath.kMessageType: ChatType.photo.rawValue
                ]
                return self.createMessage(content: content, conversation: conversation)
            }
    }
}
