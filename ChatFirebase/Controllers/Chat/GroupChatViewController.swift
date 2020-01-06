//
//  GroupChatViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/3/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit

class GroupChatViewController: UIViewController {
    
    private var conversationViewController: ConversationViewController!
    
    var chatAccession: ChatAccession!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let singleChat = segue.destination as? ConversationViewController {
            self.conversationViewController = singleChat
            self.conversationViewController.chatAccession = self.chatAccession
            self.observerConversation()
        }
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var canBecomeFirstResponder: Bool {
        return conversationViewController.canBecomeFirstResponder
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }

    private func observerConversation() {
        conversationViewController.conversationSubject
            .subscribe(onNext: { [weak self] (conversation) in
                self?.title = conversation.displayName
            })
            .disposed(by: conversationViewController.bag)
    }
}
