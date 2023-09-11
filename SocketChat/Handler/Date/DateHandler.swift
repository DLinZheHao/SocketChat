//
//  DateHandler.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/11.
//

import Foundation

class DateHandler {
    static let shared = DateHandler()
    
    let dateFormatter = DateFormatter()
    
    func chatSendDateTrans(dateString: String) -> Date {
        dateFormatter.dateFormat =  "yyyy/M/d ahh:mm:ss"
        dateFormatter.locale = Locale(identifier: "zh_TW") // 設置地區，確保解析正確
        if let date = dateFormatter.date(from: dateString) {
            print("解析後的日期：\(date)")
            return Date()
        } else {
            print("日期解析失敗")
        }
        return Date()
    }
}
