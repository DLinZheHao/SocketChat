//
//  SocketChatModel.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/10.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class SocketCahtModel {
    var inputBarView = SlackInputBar()
    
    var messages: [MessageForm] = []
    var currentUser: Sender?
    
    var mSocket = SocketHandler.sharedInstance.getSocket()
    var nickname = ""
    var users: [[String: Any]] = []
    var chatMessages: [Message] = []
    
    var curruentUserName: String = ""
    var currentUserID: String = ""
    
    
}
