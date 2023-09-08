//
//  SocketHandler.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import Foundation
import SocketIO

class SocketHandler: NSObject {
    static let sharedInstance = SocketHandler()
//    let socket = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])
    let socket = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [ .compress])
    var mSocket: SocketIOClient!

    var isConnectSetting: Bool = false
    var isMessageSetting: Bool = false
    
    override init() {
        super.init()
        mSocket = socket.defaultSocket
    }

    func getSocket() -> SocketIOClient {
        return mSocket
    }
    
    // 建立 server 連結
    func establishConnection() {
        mSocket.connect()
    }

    // 斷開 server 連接
    func closeConnection() {
        mSocket.disconnect()
    }
    
    func connectToServerWithNickname(nickname: String, userListCompletion: (([[String: Any]]) -> Void)?, messageCompletion: (([Message]) -> Void)?) {
        mSocket.emit("connectUser", nickname)
        
        if !isConnectSetting {
            mSocket.on("userList") { ( dataArray, ack) -> Void in
                userListCompletion?(dataArray[0] as? [[String: Any]] ?? [])
            }
            
            mSocket.on("messageLoadding") { (dataJson, socketAck) -> Void in
                print(dataJson[0])
                if let jsonString = dataJson[0] as? String {
                    let jsonData = jsonString.data(using: .utf8)
                    do {
                        let messages = try JSONDecoder().decode([String: [Message]].self, from: jsonData!)
                        if let messageArray = messages["messages"] {
                            messageCompletion?(messageArray)
                        }
                    } catch {
                        print("JSON 解碼失敗：\(error)")
                    }
                } else {
                    print("找麻煩")
                }
            }
            isConnectSetting = true
        }
        mSocket.emit("loadChatMessage")
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        mSocket.emit("exitUser", nickname)
        completionHandler()
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        mSocket.emit("chatMessage", nickname, message)
    }
    
    func getChatMessage(completionHandler: @escaping (Message) -> Void) {
        if !isMessageSetting {
            mSocket.on("newChatMessage") { dataArray, socketAck in
                let nickname = dataArray[0] as? String ?? "錯誤"
                let message = dataArray[1] as? String ?? "錯誤"
                let sendTime = dataArray[2] as? String ?? "錯誤"
                
                let newMessage = Message(nickname: nickname, message: message, sendTime: sendTime)
                
                completionHandler(newMessage)
            }
        }
    }
    
//    func getChatMessages(completion: @escaping ([String: Any]) -> Void) {
//        mSocket.emit("loadChatMessage")
//        print("結束發送 loadChatMessage")
//    }
    
}
