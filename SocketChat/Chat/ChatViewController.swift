//
//  ChatViewController.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    var curruentUserName: String = ""
    var currentUserID: String = ""
    
    var member: Member!
    var sender: Sender?
    var messages: [MessageForm] = []
    // var messageDateArray: [MessageData] = []
    
    var inputBarView = SlackInputBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputBarView.controller = self
        inputBarView.delegate = self
        inputBarView.setVC()
        setInputBarView()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}
extension ChatViewController {
    func setInputBarView() {
        inputBarType = .custom(inputBarView)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}
extension ChatViewController: MessagesDataSource {
    // MARK: 選擇目前用戶
    var currentSender: MessageKit.SenderType {
        return sender!
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelHeight(
       for message: MessageType,
       at indexPath: IndexPath,
       in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       
       return 20
     }
     
     func messageTopLabelAttributedText(
       for message: MessageType,
       at indexPath: IndexPath) -> NSAttributedString? {
       
       return NSAttributedString(
         string: message.sender.displayName,
         attributes: [.font: UIFont.systemFont(ofSize: 12)])
     }
}
extension ChatViewController: MessageCellDelegate {
    func didTapBackground(in cell: MessageCollectionViewCell) {
        hideKeyboard()
    }
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        hideKeyboard()
    }
    func didTapMessage(in cell: MessageCollectionViewCell) {
        // handle message here
        print("Meesage Tapped")
        hideKeyboard()
    }
    func didTapImage(in cell: MessageCollectionViewCell) {
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 發生錯誤時執行以下程式碼
            print("儲存失敗，錯誤訊息：\(error.localizedDescription)")
        } else {
            // 圖片成功儲存到相簿時執行以下程式碼
            print("圖片已成功儲存至相簿")
        }
    }
}
extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}
extension ChatViewController: MessagesDisplayDelegate {
    func inputBar(_: InputBarAccessoryView, textViewTextDidChangeTo _: String) {
        
    }
    // MARK: sender 的頭像
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
            
            // 根據消息設定頭像
            if let myMessage = message as? MessageForm, myMessage.sender.senderId == self.sender?.senderId {
                // 設定自定義的頭像
                // avatarView.image = ...
                // avatarView.set(avatar: Avatar(image: UIImage.asset(.user)))
                
            } else {
                // 設定預設的頭像
                // avatarView.set(avatar: Avatar(image: UIImage.asset(.profile_user)))
            }
            
        }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    // 當用戶點擊發送按鈕時調用
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
       
        inputBar.inputTextView.text = ""
        inputBarView.imageURLArray = []
        inputBarView.imageArray = []
        inputBarView.attachmentManager.invalidate()
        inputBarView.attachmentManager.reloadData()
        inputBarView.layoutIfNeeded()
        messagesCollectionView.scrollToLastItem(animated: true)
        
    }
}
