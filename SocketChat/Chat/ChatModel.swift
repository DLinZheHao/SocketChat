//
//  ChatModel.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Member {
  let name: String
  let color: UIColor
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct MessageForm: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Message: Codable {
    let nickname: String
    let message: String
    let sendTime: String
}

// 第一版測試階段 model
struct User: Codable {
    let id: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
            case id = "ID"
            case nickname
        }
}
