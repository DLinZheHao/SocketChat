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
    var viewModel = SocketChatViewModle()
    var model: SocketCahtModel!
    
    var curruentUserName: String = ""
    var currentUserID: String = ""
    
    // var sender: Sender!
    var messages: [MessageForm]!
    var inputBarView: SlackInputBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketHandler.sharedInstance.establishConnection()
        model = viewModel.socketChatModel
        setInputBarView()
        inputBarView.setVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askForNickname()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}
extension ChatViewController {
    func setInputBarView() {
        inputBarView = viewModel.setInputBarView()
        inputBarView.controller = self
        inputBarView.delegate = self
        inputBarType = .custom(inputBarView)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.count == 0 {
                self?.askForNickname()
            }
            else {
                print("使用者登入中")
                self?.model.nickname = textfield.text ?? ""
                // currentUserID 暫時還沒有，需想想暫定方法
                // sender = Sender(senderId: "01", displayName: model.nickname)
                
                SocketHandler.sharedInstance.connectToServerWithNickname(nickname: self?.model.nickname ?? "") { (userList) -> Void in
                    // 暫時不需要 user
                } messageCompletion: { [weak self] (messages) in
                    DispatchQueue.main.async {
                        // 把 server socket 傳輸的資料轉換成 messagekit chat 使用的資料型態
                        print("聊天室資料：\(messages)")
                        
                        // 因為會先確認使用者存在，確定存在後，才會進入到讀取 message 的部分
                        for mesData in messages {
                            let sendDate = DateHandler.shared.chatSendDateTrans(dateString: mesData.sendTime)
                            let messageSender = Sender(senderId: "234", displayName: mesData.nickname)
                            
                            let messageForm = MessageForm(sender: messageSender,
                                                          messageId: "test",
                                                          sentDate: sendDate,
                                                          kind: .text(mesData.message))
                            
                            self?.model.messages.append(messageForm)
                        }
                        self?.messagesCollectionView.reloadData()
                    }
                } userCompletion: { [weak self] userData in
                    // 註冊聊天室 sender
                    self?.model.currentUser = Sender(senderId: userData.id, displayName: userData.nickname)
                    
                }
                
                
            }
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
extension ChatViewController: MessagesDataSource {
    // MARK: 選擇目前用戶
    var currentSender: MessageKit.SenderType {
        return model.currentUser!
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return model.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        
        return model.messages.count
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
            if let myMessage = message as? MessageForm, myMessage.sender.senderId == model.currentUser?.senderId {
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
