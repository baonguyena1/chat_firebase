//
//  ConversationViewController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import MapKit
import MessageKit
import InputBarAccessoryView
import RxSwift
import RxCocoa
import RxFirebase

final class ConversationViewController: ChatViewController {
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let bag = DisposeBag()
    
    private var viewModel: ConversationViewModel!
    
    public private(set) var conversation: Conversation?
    
    var chatAccession: ChatAccession!
    
    public private(set) var conversationSubject = PublishRelay<Conversation>()
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        
        additionalBottomInset = 30

        super.viewDidLoad()
        
        initialViewModel()
        
        initialReactive()
        
        initialData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
//            .onTypingStatus { [weak self] in
//                self?.setTypingIndicatorViewHidden(false)
//        }.onNewMessage { [weak self] message in
//            self?.setTypingIndicatorViewHidden(true, performUpdates: {
//                self?.insertMessage(message)
//            })
//        }
    }
    
    override func loadFirstMessages() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let count = UserDefaults.standard.mockMessagesCount()
//            SampleData.shared.getAdvancedMessages(count: count) { messages in
//                DispatchQueue.main.async {
//                    self.messageList = messages
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToBottom()
//                }
//            }
//        }
    }
    
    override func loadMoreMessages() {
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getAdvancedMessages(count: 20) { messages in
//                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
    }
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

        // Set incoming avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        layout?.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func configureMessageInputBar() {
        super.configureMessageInputBar()
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = ColorAssets.primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = ImageAssets.ic_up
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.middleContentViewPadding.right = -38
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = ColorAssets.primaryColor
                })
        }.onDisabled { item in
            UIView.animate(withDuration: 0.3, animations: {
                item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
            })
        }
    }
    
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 25), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onSelected {
            $0.tintColor = ColorAssets.primaryColor
        }.onDeselected {
            $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onTouchUpInside {
            print("Item Tapped")
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let action = UIAlertAction(title: Localizable.kCancel, style: .cancel, handler: nil)
            actionSheet.addAction(action)
            if let popoverPresentationController = actionSheet.popoverPresentationController {
                popoverPresentationController.sourceView = $0
                popoverPresentationController.sourceRect = $0.frame
            }
            self.navigationController?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
//        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
//        if case .custom = message.kind {
//            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
//            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
//            return cell
//        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - MessagesDataSource
    
    override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
            case .hashtag, .mention:
                if isFromCurrentSender(message: message) {
                    return [.foregroundColor: UIColor.white]
                } else {
                    return [.foregroundColor: ColorAssets.primaryColor]
            }
            default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? ColorAssets.primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let user = self.conversation?.users.first(where: { $0.documentID == message.sender.senderId }) {
            let url = URL(string: user.avatar ?? "")
            avatarView.kf.setImage(with: url, placeholder: nil)
        } else {
            let avatar = getAvatarFor(sender: message.sender)
            avatarView.set(avatar: avatar)
        }
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = ColorAssets.primaryColor.cgColor
    }
    
//    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        // Cells are reused, so only add a button here once. For real use you would need to
//        // ensure any subviews are removed if not needed
//        accessoryView.subviews.forEach { $0.removeFromSuperview() }
//        accessoryView.backgroundColor = .clear
//        
//        let shouldShow = Int.random(in: 0...10) == 0
//        guard shouldShow else { return }
//        
//        let button = UIButton(type: .infoLight)
//        button.tintColor = ColorAssets.primaryColor
//        accessoryView.addSubview(button)
//        button.frame = accessoryView.bounds
//        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
//        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
//        accessoryView.backgroundColor = ColorAssets.primaryColor.withAlphaComponent(0.3)
//    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return self.isFromCurrentSender(message: message) ? .white : ColorAssets.primaryColor
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
}

extension ConversationViewController {
    
    override func sendMessages(_ data: [Any]) {
        guard let chatAccession = self.chatAccession else {
            return
        }
        switch chatAccession {
            case .history(let conversationId):
                viewModel.createNewMessages(sender: currentSender().senderId, conversation: conversationId, data: data)
            case .friend(let listFriend):   // Initial new conversation
                let members = [currentSender().senderId] + listFriend
                viewModel.initialConversation(members: members, sender: currentSender().senderId, data: data)
        }
    }
    
    private func finishSentMessage() {
        self.messageInputBar.sendButton.stopAnimating()
        self.messageInputBar.inputTextView.placeholder = Localizable.kAa
    }
}

extension ConversationViewController {
    func getAvatarFor(sender: SenderType) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").last
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        return Avatar(image: nil, initials: initials)
    }
}

extension ConversationViewController {
    
    private func initialViewModel() {
        viewModel = ConversationViewModel(sender: currentSender() as! SenderUser)
    }
    
    private func initialReactive() {
        viewModel.sentMessageStatus
            .filter { !$0 }
            .subscribe(onNext: { [weak self] (_) in
                self?.finishSentMessage()
            })
            .disposed(by: bag)
        
        // Observe conversation id when create the new conversation
        viewModel.conversationId
            .subscribe(onNext: { [weak self] (conversationId) in
                self?.setConversationId(id: conversationId)
            })
            .disposed(by: bag)
        
        // Observe conversation when get the conversation
        viewModel.conversation.share()
            .subscribe(onNext: { [weak self] (conversation) in
                self?.conversation = conversation
                self?.conversationSubject.accept(conversation)
                self?.viewModel.observeMessages(inConversation: conversation.documentID)
            })
            .disposed(by: bag)
        
        viewModel.messages
            .subscribe(onNext: { [weak self] (messages) in
                let list = messages.compactMap { self?.chatMessageFromMessage($0) }
                self?.messageList = list
                DispatchQueue.main.async { [weak self] in
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
            .disposed(by: bag)
    }
    
    private func chatMessageFromMessage(_ message: Message) -> ChatMessage {
        guard let user = self.conversation?.users.first(where: { message.senderId == $0.documentID } ) else { fatalError() }
        let sender = SenderUser(senderId: user.documentID, displayName: user.displayName ?? "")
        return ChatMessage(text: message.message, user: sender, messageId: message.documentID, date: message.createdAt.date)
    }
    
    private func initialData() {
        Logger.log("\(chatAccession)")
        guard let chatAccession = self.chatAccession else {
            return
        }
        switch chatAccession {
            case .history(let conversationId):
                viewModel.observeConversation(conversationId: conversationId)
            case .friend(let listFriend): // Check conversation exist
                let members = [currentSender().senderId] + listFriend
                viewModel.getHistoryLog(members: members)
        }
    }
    
    private func setConversationId(id: String) {
        Logger.log("\(id)")
        self.chatAccession = .history(conversationId: id)
        viewModel.observeConversation(conversationId: id)
    }
}
