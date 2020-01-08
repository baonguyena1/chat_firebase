//
//  GroupInfoViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/7/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

class GroupInfoViewModel: BaseViewModel {
    var rx_isLoading = PublishRelay<Bool>()
    var rx_error = PublishRelay<String>()
    
    private let bag = DisposeBag()
    
    private(set) var conversation = PublishRelay<Conversation>()
    
    private(set) var leaveGroup = PublishRelay<Void>()
    
    private(set) var deleteGroup = PublishRelay<Void>()
    
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
    
    func changeGroupName(name: String, conversation: String) {
        rx_isLoading.accept(true)
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        conversationRef.rx.updateData([
                KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
                KeyPath.kName: name
            ])
            .subscribe(onNext: { (_) in
                
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    func changeGroupPhoto(image: UIImage, previousLink: String, conversation: String) {
        let imagename = UUID().uuidString.lowercased()
        let reference = FireBaseManager.shared.chatAvatarStorage.child(conversation).child(imagename + ".png")
        rx_isLoading.accept(true)
        FireBaseManager.shared.uploadGetDelete(image, previousLink: previousLink, reference: reference)
            .flatMap { (url) -> Observable<Void> in
                let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
                let data: [String: Any] = [
                    KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
                    KeyPath.kAvatar: url
                ]
                return conversationRef.rx.updateData(data)
            }
            .subscribe(onNext: { (_) in
                
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    func removePhoto(_ photo: String, conversation: String) {
        rx_isLoading.accept(true)
        let updatedData: [String: Any] = [
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kAvatar: FieldValue.delete()
        ]
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        Observable.zip(FireBaseManager.shared.deleteImage(urlString: photo), conversationRef.rx.updateData(updatedData))
            .subscribe(onNext: { (_, _) in
                
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    func leaveGroup(user: String, conversation: String) {
        rx_isLoading.accept(true)
        Observable.zip(leaveConversation(user: user, conversation: conversation), leaveUserChat(user: user, conversation: conversation))
            .subscribe(onNext: { [weak self] (_, _) in
                self?.leaveGroup.accept(())
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
            .disposed(by: bag)
    }
    
    private func leaveConversation(user: String, conversation: String) -> Observable<Void> {
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        let data: [String: Any] = [
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kActiveMembers: FieldValue.arrayRemove([user])
        ]
        return conversationRef.rx.updateData(data)
    }
    
    private func leaveUserChat(user: String, conversation: String) -> Observable<Void> {
        let userChatRef = FireBaseManager.shared.userChatsCollection.document(user)
        let data: [String: Any] = [
            KeyPath.kUpdatedAt: Date().milisecondTimeIntervalSince1970,
            KeyPath.kConversations: FieldValue.arrayRemove([conversation])
        ]
        return userChatRef.rx.updateData(data)
    }
    
    func deteleConversation(conversation: String, activeMembers: [String]) {
        let conversationRef = FireBaseManager.shared.conversationsCollection.document(conversation)
        self.rx_isLoading.accept(true)
        conversationRef.rx.delete()
            .subscribe(onNext: { [weak self] (_) in
                self?.deleteGroup.accept(())
            }, onError: { [weak self] (error) in
                self?.rx_error.accept(error.localizedDescription)
                self?.rx_isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.rx_isLoading.accept(false)
            })
        .disposed(by: bag)
        
    }
    
}
