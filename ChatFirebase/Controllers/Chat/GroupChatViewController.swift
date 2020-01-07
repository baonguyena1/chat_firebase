//
//  GroupChatViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 1/3/20.
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

import UIKit

class GroupChatViewController: UIViewController {
    
    @IBOutlet weak var groupInfoButton: UIBarButtonItem!
    
    private var conversationViewController: ConversationViewController!
    
    var chatAccession: ChatAccession!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupInfoButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let singleChat = segue.destination as? ConversationViewController {
            self.conversationViewController = singleChat
            self.conversationViewController.chatAccession = self.chatAccession
            self.observerConversation()
        } else if let groupInfoController = segue.destination as? GroupInfoViewController,
            let conversation = self.conversationViewController.conversation {
            groupInfoController.conversation = conversation
        } else if let navigationController = segue.destination as? UINavigationController {
            if let conversation = self.conversationViewController.conversation {
                if let addPeopleController = navigationController.viewControllers.first as? AddPeopleViewController {
                    addPeopleController.conversation = conversation
                }
            }
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
                self?.groupInfoButton.isEnabled = true
            })
            .disposed(by: conversationViewController.bag)
    }
}
