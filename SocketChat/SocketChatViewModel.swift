//
//  SocketChatModel.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/10.
//

import Foundation
import Network

class SocketChatViewModle {
    var socketChatModel = SocketCahtModel()
    

    func setInputBarView() -> SlackInputBar {
        return socketChatModel.inputBarView
    }
    
    func getMessages() -> [MessageForm] {
        return socketChatModel.messages
    }
    
    func getSender() -> Sender? {
        return socketChatModel.currentUser ?? nil
    }
    
    // 在輸入 nickName 後，建立 currentUser (Sender)
    func setSender() {
        // 把資料儲存進入 Model
    }
}
