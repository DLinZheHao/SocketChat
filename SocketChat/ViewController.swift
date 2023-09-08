//
//  ViewController.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import UIKit
import Network

class ViewController: UIViewController {

    var mSocket = SocketHandler.sharedInstance.getSocket()
    var nickname = ""
    var users: [[String: Any]] = []
    var chatMessages: [Message] = []
    
    @IBOutlet weak var labelCounter: UILabel!
    @IBOutlet weak var meaageLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var userListTableView: UITableView! {
        didSet {
            userListTableView.delegate = self
            userListTableView.dataSource = self
            userListTableView.registerCellWithNib(identifier: String(describing: UserStatusCell.self), bundle: nil)
        }
    }
    
    @IBOutlet weak var messageTableView: UITableView! {
        didSet {
            messageTableView.delegate = self
            messageTableView.dataSource = self
            messageTableView.registerCellWithNib(identifier: String(describing: MessageCell.self), bundle: nil)
        }
    }
    
    @IBAction func btnCounter(_ sender: Any) {
        //mSocket.emit("counter")
        //mSocket.emit("chatMessage", ["message": "Hello, World!"])
    }

    @IBAction func btnUserConnect(_ sender: Any) {
        // SocketHandler.sharedInstance.connectToServerWithNickname(nickname: "LinZheHao", completionHandler: nil)
    }
    
    @IBAction func btnMessageLoadding(_ sender: Any) {
//        SocketHandler.sharedInstance.getChatMessages(completion: { dataArray in
//            print("截數")
//        })
    }
    
    @IBAction func btnUserExit(_ sender: Any) {
        SocketHandler.sharedInstance.exitChatWithNickname(nickname: nickname) {
            DispatchQueue.main.async {
                self.nickname = ""
                self.chatMessages = []
                self.users.removeAll()
                self.userListTableView.isHidden = true
                self.messageTableView.isHidden = true
                self.askForNickname()
            }
        }
    }
    @IBAction func sendMessage(sender: AnyObject) {
        if messageTextField.text!.count > 0 {
            SocketHandler.sharedInstance.sendMessage(message: messageTextField.text!, withNickname: nickname)
            messageTextField.text = ""
            messageTextField.resignFirstResponder()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        SocketHandler.sharedInstance.establishConnection()
        
        mSocket.on("counter") { ( dataArray, ack) -> Void in
            let dataReceived = dataArray[0] as! String
            self.labelCounter.text = "\(dataReceived)"
        }
        
        mSocket.on("chatMessage") { ( dataArray, ack) -> Void in
            let dataReceived = dataArray[0] as! [String: Any]
            print("結果：\(dataReceived)")
            self.meaageLabel.text = "\(dataReceived)"
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname.isEmpty {
            askForNickname()
        }
        SocketHandler.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.chatMessages.append(messageInfo)
                print("讀取訊息：\(messageInfo)")
                self.messageTableView.reloadData()
            }
         }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == userListTableView {
            return users.count
        } else {
            return chatMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == userListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserStatusCell.self), for: indexPath)
            
            guard let userStatusCell = cell as? UserStatusCell else {
                return cell
            }
            
            userStatusCell.userNikenameLabel.text = users[indexPath.row]["nickname"] as? String ?? "未讀取"
            userStatusCell.isConntectLabel.text = (users[indexPath.row]["isConnected"] as! Bool) ? "上線" : "離線"
            userStatusCell.isConntectLabel.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? .green : .red
            
            return userStatusCell
        } else if tableView == messageTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self), for: indexPath)
            
            guard let messageCell = cell as? MessageCell else {
                print("失敗")
                return cell
            }

            messageCell.messageLabel.text = chatMessages[indexPath.row].message
            messageCell.messageLabel.tintColor = .black
            return messageCell
        }

        print("錯誤執行")
        return UITableViewCell()
        
    }
    
}

extension ViewController {
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text ?? ""
                
                SocketHandler.sharedInstance.connectToServerWithNickname(nickname: self.nickname) { (userList) -> Void in
                    DispatchQueue.main.async {
                        if !userList.isEmpty {
                            self.users = userList
                            self.userListTableView.reloadData()
                            self.userListTableView.isHidden = false
                            self.messageTableView.reloadData()
                            self.messageTableView.isHidden = false
                        }
                    }
                } messageCompletion: { (messages) in
                    DispatchQueue.main.async {
                        self.chatMessages = messages
                        self.messageTableView.reloadData()
                    }
                }
            }
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}

//class ViewController: UIViewController {
//
//    var connection: NWConnection?
//    @IBOutlet weak var labelCounter: UILabel!
//
//    @IBAction func btnCounter(_ sender: Any) {
//        // Send a "counter" event (you need to define the actual data format)
//        let eventName = "counter" // Define your event name
//
//        // Send an empty data payload
//        let data = Data()
//
//        connection?.send(content: data, completion: .contentProcessed { error in
//            if let error = error {
//                print("Sending error: \(error)")
//            } else {
//                print("Event sent successfully: \(eventName)")
//            }
//        })
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        establishConnection()
//        startListening()
//    }
//
//    func establishConnection() {
//        let endpoint = NWEndpoint.hostPort(host: "172.20.10.12", port: 8080)
//        connection = NWConnection(to: endpoint, using: .tcp)
//
//        connection?.stateUpdateHandler = { newState in
//            switch newState {
//            case .ready:
//                print("Socket connection established")
//            case .waiting(let error):
//                print("Socket connection waiting: \(error)")
//            case .failed(let error):
//                print("Socket connection failed: \(error)")
//            default:
//                break
//            }
//        }
//
//        connection?.start(queue: .main)
//    }
//
//    func startListening() {
//        // Start listening for incoming data (you need to define the actual data format)
//        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, error in
//            if let data = data, !data.isEmpty {
//                // Process the received data (you need to handle the actual data format)
//                let receivedString = String(data: data, encoding: .utf8)
//                DispatchQueue.main.async {
//                    self.labelCounter.text = receivedString
//                }
//            }
//
//            if let error = error {
//                print("Receiving error: \(error)")
//            } else {
//                self.startListening() // Continue listening
//            }
//        }
//    }
//
//    deinit {
//        connection?.cancel() // Close the connection when the view controller is deallocated
//    }
//}
