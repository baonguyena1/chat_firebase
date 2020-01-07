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

class GroupInfoViewModel: BaseViewModel {
    var rx_isLoading = PublishRelay<Bool>()
    var rx_error = PublishRelay<String>()
    
    private let bag = DisposeBag()
    
    private(set) var conversation = PublishRelay<Conversation>()
    
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
    
    func changeGroupPhoto(image: UIImage, conversation: String) {
        
    }
}
