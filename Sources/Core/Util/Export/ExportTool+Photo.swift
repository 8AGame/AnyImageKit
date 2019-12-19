//
//  ExportTool+Photo.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public struct PhotoFetchOptions {

    public let size: CGSize
    public let resizeMode: PHImageRequestOptionsResizeMode
    public let version: PHImageRequestOptionsVersion
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?

    public init(size: CGSize = PHImageManagerMaximumSize,
                resizeMode: PHImageRequestOptionsResizeMode = .fast,
                version: PHImageRequestOptionsVersion = .current,
                isNetworkAccessAllowed: Bool = true,
                progressHandler: PHAssetImageProgressHandler? = nil) {
        self.size = size
        self.resizeMode = resizeMode
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

public struct PhotoFetchResponse {

    public let image: UIImage
    public let isDegraded: Bool
}

public typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>, PHImageRequestID) -> Void
public typealias PhotoSaveCompletion = (Result<PHAsset, ImagePickerError>) -> Void

extension ExportTool {
    
    @discardableResult
    public static func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.resizeMode = options.resizeMode
        requestOptions.isSynchronous = false

        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: options.size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            guard let info = info else {
                completion(.failure(.invalidInfo), requestID)
                return
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                completion(.success(.init(image: image, isDegraded: isDegraded)), requestID)
            } else {
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud {
                    completion(.failure(ImagePickerError.cannotFindInLocal), requestID)
                } else {
                    completion(.failure(ImagePickerError.invalidData), requestID)
                }
            }
        }
        return requestID
    }

    public static func savePhoto(_ image: UIImage, metadata: [String: Any] = [:], completion: PhotoSaveCompletion? = nil) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion?(.failure(.savePhotoFail))
            return
        }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let filePath = NSTemporaryDirectory().appending("PHOTO-SAVED-\(timestamp).jpg")
        FileHelper.createDirectory(at: NSTemporaryDirectory())
        let url = URL(fileURLWithPath: filePath)
        // Write to file
        do {
            try imageData.write(to: url)
        } catch {
            completion?(.failure(.savePhotoFail))
        }

        // Write to album library
        var localIdentifier: String = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (isSuccess, error) in
            try? FileManager.default.removeItem(atPath: filePath)
            DispatchQueue.main.async {
                if isSuccess {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        completion?(.success(asset))
                    } else {
                        completion?(.failure(.savePhotoFail))
                    }
                } else if error != nil {
                    _print("Save photo error: \(error!.localizedDescription)")
                    completion?(.failure(.savePhotoFail))
                }
            }
        }
    }
}

