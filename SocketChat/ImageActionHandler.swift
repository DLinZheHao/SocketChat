//
//  ImageActionHandler.swift
//  SocketChat
//
//  Created by 林哲豪 on 2023/9/9.
//

import Foundation
import UIKit
import Photos

class ImageActionHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var completionHandler: ((URL?) -> Void)?
    var controller: UIViewController?
    var imageArray: [UIImage] = []
    var imageURLArray: [URL] = []
    
    var selectedFileURL: URL?
    
    init(controller: UIViewController) {
        self.controller = controller
        super.init()
    }
    
    func getImageGo(type: Int) {
        let takingPicture = UIImagePickerController()
        takingPicture.sourceType = (type == 1) ? .camera : .photoLibrary
        takingPicture.allowsEditing = false
        takingPicture.delegate = self
        controller?.present(takingPicture, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let originalImage = info[.originalImage] as? UIImage {
            imageArray.append(originalImage)
            let handled = self.handleInput(of: originalImage)
            if !handled {
                print("错误")
            }
            
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                imageURLArray.append(imageURL)
                print("获取相册照片成功: \(imageURL)")
            } else {
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    self?.imageURLArray.append(photoUrl!)
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            imageArray.append(editedImage)
            
            saveImageToPhotoAlbum(editedImage) { [weak self] photoUrl in
                self?.selectedFileURL = photoUrl
            }
        }
    }
    
    func saveImageToPhotoAlbum(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        self.completionHandler = completion
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("无法存储照片: \(error.localizedDescription)")
            self.completionHandler?(nil)
        } else {
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
    
    func handleInput(of image: UIImage) -> Bool {
        // 在这里处理图片输入，可以根据需要扩展
        return true
    }
}
