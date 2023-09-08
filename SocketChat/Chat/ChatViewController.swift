//
//  ChatViewController.swift
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
class ChatViewController: MessagesViewController {
    var curruentUserName: String = ""
    var currentUserID: String = ""
    
    var member: Member!
    var sender: Sender?
    var messages: [MessageForm] = []
    // var messageDateArray: [MessageData] = []
    
    let inputBarView = SlackInputBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//        sender = Sender(senderId: currentUserID, displayName: curruentUserName)
//        sender!.senderId = currentUserID
//
//        messageDateArray = findNewMessages(existingMessages: messageDateArray, newMessages: dataArray)
//
//        for messageData in self!.messageDateArray {
//            if messageData.action == 0 {
//                let sender = Sender(senderId: messageData.senderID, displayName: messageData.name)
//                let message = MessageForm(sender: sender,
//                                          messageId: messageData.id,
//                                          sentDate: Date(timeIntervalSince1970: messageData.sendDate),
//                                          kind: .text(messageData.textContent))
//                self?.messages.append(message)
//            } else if messageData.action == 1 {
//                let sender = Sender(senderId: messageData.senderID, displayName: messageData.name)
//                let url = URL(string: messageData.url)!
//
//                // 創建占位圖片消息
//                let placeholderImage = UIImage.asset(.fridge)
//                let placeholderMediaItem = Media(url: url,
//                                                 image: nil,
//                                                 placeholderImage: placeholderImage!,
//                                                 size: .zero)
//                let placeholderMessage = MessageForm(sender: sender,
//                                                     messageId: messageData.id,
//                                                     sentDate: Date(timeIntervalSince1970: messageData.sendDate),
//                                                     kind: .photo(placeholderMediaItem))
//                self?.messages.append(placeholderMessage)
//
//                ImageDownloader.shared.downloadImage(from: url) {[weak self] (image) in
//                    if let image = image {
//                        guard let self = self else { return }
//
//                        // 更新圖片消息
//                        if let index = self.messages.firstIndex(where: { $0.messageId == messageData.id }) {
//                            let mediaItem = Media(url: url,
//                                                  image: image,
//                                                  placeholderImage: placeholderImage!,
//                                                  size: image.size)
//                            let updatedMessage = MessageForm(sender: sender,
//                                                             messageId: messageData.id,
//                                                             sentDate: Date(timeIntervalSince1970: messageData.sendDate),
//                                                             kind: .photo(mediaItem))
//                            self.messages[index] = updatedMessage
//                            self.messagesCollectionView.reloadData()
//                        }
//                    } else {
//                        // 下载失败或图像无效
//                        print("載入圖片失敗")
//                    }
//                }
//
//            }
//        }
//        messageDateArray = dataArray
//        messagesCollectionView.reloadData()
//        messagesCollectionView.scrollToLastItem(animated: true)
//        messagesCollectionView.messageCellDelegate = self
//
//
//        inputBarView.delegate = self
//        inputBarView.controller = self
//
//        inputBarType = .custom(inputBarView)
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
        
        navigationItem.title = "留言"
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
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
