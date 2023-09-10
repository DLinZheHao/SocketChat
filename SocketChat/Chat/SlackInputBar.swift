//
//  SlackInputBar.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import Photos

final class SlackInputBar: InputBarAccessoryView {
    var imageActionHandler: ImageActionHandler?
    var imageArray = [UIImage]()
    var imageURLArray = [URL]()
    
    public lazy var attachmentManager: AttachmentManager = { [unowned self] in
        print("創建")
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    var takingPicture: UIImagePickerController!
    var imageURL: String?
    var selectedFileURL: URL?
    
    var completionHandler: ((URL?) -> Void)?
    var getImageCompletionHandler: ((UIImage) -> Void)?
    
    var controller: ChatViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        self.inputPlugins = [attachmentManager]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVC() {
        imageActionHandler = ImageActionHandler(controller: controller!)
    }
    
    func configure() {
        let items = [
            makeButton(named: "ic_camera")
                .onSelected { [self] in
                    $0.tintColor = .systemBlue
                    imageActionHandler?.getImageGo(type: 1)
            },
            makeButton(named: "ic_library")
                .onSelected { [self] in
                    $0.tintColor = .systemBlue
                    imageActionHandler?.getImageGo(type: 2)

            },
            .flexibleSpace,
            sendButton
                .configure {
                    $0.setTitle("發送", for: .normal)
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: false)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .clear
                }.onEnabled {
                    $0.backgroundColor = .systemBlue
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        ]
        items.forEach { $0.tintColor = UIColor.lightGray }
        
        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        let maxSizeItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate)
                $0.tintColor = .darkGray
                $0.setSize(CGSize(width: 20, height: 20), animated: false)
            }.onSelected {
                let oldValue = $0.inputBarAccessoryView?.shouldForceTextViewMaxHeight ?? false
                $0.image = oldValue ? UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icons8-collapse")?.withRenderingMode(.alwaysTemplate)
                self.setShouldForceMaxTextViewHeight(to: !oldValue, animated: true)
        }
        rightStackView.alignment = .top
        setStackViewItems([maxSizeItem], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 20, animated: false)
        
        // Finally set the items
        setStackViewItems(items, forStack: .bottom, animated: false)

        shouldAnimateTextDidChangeLayout = true
    }
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    
}
extension SlackInputBar: AttachmentManagerDelegate {
    
    // MARK: - AttachmentManagerDelegate
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let albumAction = UIAlertAction(title: "相簿", style: .default) { [weak self] (_) in
            self?.imageActionHandler?.getImageGo(type: 2)
        }
        let takePictureAction = UIAlertAction(title: "拍照", style: .default) { [weak self] (_)  in
            self?.imageActionHandler?.getImageGo(type: 1)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionSheet.addAction(albumAction)
        actionSheet.addAction(takePictureAction)
        actionSheet.addAction(cancelAction)

        controller!.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    func setAttachmentManager(active: Bool) {
        print("觸發６")
        let topStackView = self.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView,
                                               at: topStackView.arrangedSubviews.count)
            DispatchQueue.main.async {
                self.topStackView.layoutIfNeeded()
                self.topStackView.setNeedsLayout()
            }
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            DispatchQueue.main.async {
                self.topStackView.setNeedsLayout()
                self.topStackView.layoutIfNeeded()
                
            }
        }
    }
}
