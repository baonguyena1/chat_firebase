//
//  ChatMessage.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/27/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit
import AVFoundation

private struct CoordinateItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

struct ImageMediaItem: MediaItem {
    
    var urlString: String?
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(urlString: String?) {
        self.urlString = urlString
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

private struct MessageAudiotem: AudioItem {
    
    var url: URL
    var size: CGSize
    var duration: Float
    
    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }
    
}

struct MessageContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

class ChatMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind
    
    var user: SenderUser
    
    private init(kind: MessageKind, user: SenderUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    convenience init(custom: Any?, user: SenderUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }
    
    convenience init(text: String, user: SenderUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
    
    convenience init(attributedText: NSAttributedString, user: SenderUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }
    
    convenience init(image: UIImage, user: SenderUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(urlString: String?, user: SenderUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(urlString: urlString)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(thumbnail: UIImage, user: SenderUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(location: CLLocation, user: SenderUser, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(emoji: String, user: SenderUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }
    
    convenience init(audioURL: URL, user: SenderUser, messageId: String, date: Date) {
        let audioItem = MessageAudiotem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(contact: MessageContactItem, user: SenderUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }
}
