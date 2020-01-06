//
//  AddPeopleViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/6/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

class AddPeopleViewModel: BaseViewModel {
    private(set) lazy var rx_isLoading = PublishRelay<Bool>()
    private(set) lazy var rx_error = PublishRelay<String>()
    
    private let bag = DisposeBag()
    
    private(set) var members = BehaviorRelay<[User]>(value: [])
    
    private(set) var addMembersSuccess = PublishRelay<Void>()
    
    var addMembers = BehaviorRelay<Set<String>>(value: Set<String>())
    
    var addButtonEnabled: Observable<Bool> {
        return addMembers.asObservable().compactMap { !$0.isEmpty }
    }
    
    func observeMembers(without members: [String]) {
        let auth = FireBaseManager.shared.auth
        let usersCollection = FireBaseManager.shared.usersCollection
        usersCollection.rx
            .listen()
            .subscribe(onNext: { [weak self] (snapshot) in
                
                guard let `self` = self else { return }
                var currents = self.members.value
                snapshot.documentChanges
                    .lazy
                    .filter { !members.contains($0.document.documentID) }
                    .forEach {(diff) in
                        var data = diff.document.data()
                        data[KeyPath.kDocumentID] = diff.document.documentID
                        let user = User(from: data)
                        switch diff.type {
                            case .added:
                                if user.documentID != auth.currentUser?.uid {
                                    currents.append(user)
                            }
                            case .modified:
                                if let index = currents.firstIndex(where: { $0.documentID == user.documentID }) {
                                    currents[index] = user
                            }
                            case .removed:
                                if let index = currents.firstIndex(where: { $0.documentID == user.documentID }) {
                                    currents.remove(at: index)
                            }
                        }
                    }
                    currents.sort { (u1, u2) -> Bool in
                        u1.createdAt > u2.createdAt
                    }
                    self.members.accept(currents)
                    }, onError: { (error) in
                        Logger.error(error.localizedDescription)
                })
                .disposed(by: bag)
    }
    
    func isMemberContains(_ member: String) -> Bool {
        return addMembers.value.contains(member)
    }
    
    func addOrRemoveMember(_ member: String) {
        var current = addMembers.value
        if current.contains(member) {
            current.remove(member)
        } else {
            current.insert(member)
        }
        self.addMembers.accept(current)
    }
    
    func addMembersToConversation(members: [String], conversation: String) {
        self.rx_isLoading.accept(true)
        Observable.zip(appendMemberToConversation(members: members, conversation: conversation),
                       addOrUpdateUserChats(members: members, conversation: conversation))
            .subscribe(onNext: { [weak self] (_, _) in
                self?.addMembersSuccess.accept(())
            }, onError: { [weak self] (error) in
                Logger.error(error.localizedDescription)
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    private func appendMemberToConversation(members: [String], conversation: String) -> Observable<Void> {
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        let data: [String: Any] = [
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kMembers: FieldValue.arrayUnion(members)
        ]
        return conversationRef.rx.updateData(data)
    }
    
    private func addOrUpdateUserChats(members: [String], conversation: String) -> Observable<Void> {
        let updatedUserChats = members.map { self.addOrUpdateUserChat(member: $0, conversation: conversation) }
        return Observable.zip(updatedUserChats)
            .flatMap { (_) -> Observable<Void> in
                .just(())
            }
    }
    
    private func addOrUpdateUserChat(member: String, conversation: String) -> Observable<Void> {
        let userChatRef = FireBaseManager.shared.userChatsCollection.document(member)
        return FireBaseManager.shared.documentExists(docRef: userChatRef)
            .flatMap { (exists) -> Observable<Void> in
                var data: [String: Any] = [ KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970 ]
                if exists {
                    data[KeyPath.kConversations] = FieldValue.arrayUnion([conversation])
                    return userChatRef.rx.updateData(data)
                }
                data[KeyPath.kConversations] =  [conversation]
                return userChatRef.rx.setData(data)
        }
    }
}
