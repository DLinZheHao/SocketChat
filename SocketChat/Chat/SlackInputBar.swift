//
//  SlackInputBar.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/8.
//

import Foundation
import UIKit
import InputBarAccessoryView
import Photos

final class SlackInputBar: InputBarAccessoryView {
    
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
    
    func configure() {
        let items = [
            makeButton(named: "ic_camera")
                .onSelected { [self] in
                    $0.tintColor = .systemBlue
                    getImageGo(type: 1)
            },
            makeButton(named: "ic_library")
                .onSelected { [self] in
                    $0.tintColor = .systemBlue
                    getImageGo(type: 2)

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

extension SlackInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 去拍照或者去相册选择图片
    func getImageGo(type: Int) {
        takingPicture = UIImagePickerController.init()
        if type == 1 {
            takingPicture.sourceType = .camera
            // 拍照时是否显示工具栏
            // takingPicture.showsCameraControls = true
        } else if type == 2 {
            takingPicture.sourceType = .photoLibrary
        }
        // 是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = false
        takingPicture.delegate = self
        controller!.present(takingPicture, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        takingPicture.dismiss(animated: true, completion: nil)

        if let originalImage = info[.originalImage] as? UIImage {
            self.imageArray.append(originalImage)
            let handled = self.attachmentManager.handleInput(of: originalImage)
            if !handled {
                print("錯誤")
            }
            // 照片來自相簿
            // image.image = originalImage
            // getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                self.imageURLArray.append(imageURL)
                print("獲取相簿照片成功: \(imageURL)")
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    self?.imageURLArray.append(photoUrl!)
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            // 拍攝的照片
            self.imageArray.append(editedImage)
//            let handled = self.attachmentManager.handleInput(of: editedImage)
            // image.image = editedImage
            // getImageCompletionHandler!(editedImage)
            // 將照片存儲到相冊並獲取 URL
            saveImageToPhotoAlbum(editedImage) { [weak self] photoUrl in
                self?.selectedFileURL = photoUrl
            }
        }
    }
    func saveImageToPhotoAlbum(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // 在 `image(_:didFinishSavingWithError:contextInfo:)` 中獲取 URL
        self.completionHandler = completion
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("無法存儲照片: \(error.localizedDescription)")
            self.completionHandler?(nil)
        } else {
            // 從相冊中獲取最新的照片 URL
            fetchNewestPhotoURL { url in
                self.completionHandler?(url)
            }
        }
    }

    func fetchNewestPhotoURL(completion: @escaping (URL?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let asset = fetchResult.firstObject {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ in true }
            
            asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
                completion(contentEditingInput?.fullSizeImageURL)
            }
        } else {
            completion(nil)
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
            self?.getImageGo(type: 2)
        }
        let takePictureAction = UIAlertAction(title: "拍照", style: .default) { [weak self] (_)  in
            self?.getImageGo(type: 1)
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
