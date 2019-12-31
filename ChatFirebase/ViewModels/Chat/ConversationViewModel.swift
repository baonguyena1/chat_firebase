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
            .flatMapLatest { (snapshot) -> Observable<Conversation?> in
                guard let data = snapshot.data(),
                    let conversations = data[KeyPath.kConversations] as? [String] else {
                        return Observable.just(nil)
                }
                let conversationsObservable = conversations.compactMap { FireBaseManager.shared.observeConversation(conversation: $0) }
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
    
    private func addConversation(conversation: Conversation) {
        var conversations = self.conversations.value
        if let index = conversations.firstIndex(where: { $0.documentID == conversation.documentID }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
        conversations.sort { (c1, c2) -> Bool in
            return c1.updatedAt > c2.updatedAt
        }
        self.conversations.accept(conversations)
    }
    
}
