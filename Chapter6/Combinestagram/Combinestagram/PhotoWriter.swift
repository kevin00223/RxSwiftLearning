//
//  PhotoWriter.swift
//  Combinestagram
//
//  Created by 李凯 on 2019/7/30.
//  Copyright © 2019 LK. All rights reserved.
//

import Foundation
import RxSwift
import Photos

enum Errors: Error {
    case couldNotSavePhoto
}

/*
 自定义Observable
 */
class PhotoWriter: NSObject {
    
    // 保存图片的函数. 返回一个字符串类型的observable, 用来发出图片对应的ID
    static func save(_ image: UIImage) -> Observable<String> {
        // Observale.create用来创建一个新的observable
        return Observable.create({ observer -> Disposable in
            var savedAssetId: String?
            PHPhotoLibrary.shared().performChanges({
                // 获取图片的id
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { success, error in
                // 获取图片id完成后, 进入该回调
                // 成功 就发送id
                DispatchQueue.main.async {
                    if success {
                        if let id = savedAssetId {
                            observer.onNext(id)
                            observer.onCompleted()
                        }
                    }else{
                        // 否则就发送错误
                        observer.onError(error ?? Errors.couldNotSavePhoto)
                    }
                }
            })
            return Disposables.create()
        })
    }
    
    // 返回Single<String>函数
    static func keep(_ image: UIImage) -> Single<String> {
        return Single.create { single in
            var savedAssetId: String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        if let id = savedAssetId {
                            single(.success(id))
                        }
                    }else{
                        single(.error(error ?? Errors.couldNotSavePhoto))
                    }
                }
            })
            return Disposables.create()
        }
    }
    
}
