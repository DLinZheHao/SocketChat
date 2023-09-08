//
//  Message.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import Foundation

struct Message: Codable {
    let nickname: String
    let message: String
    let sendTime: String
}
