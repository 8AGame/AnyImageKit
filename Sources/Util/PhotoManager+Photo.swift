//
//  PhotoManager+Photo.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import UIKit

struct PhotoFetchOptions {
    
    let sizeMode: PhotoSizeMode
    let resizeMode: PHImageRequestOptionsResizeMode
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(sizeMode: PhotoSizeMode = .resize(100),
         resizeMode: PHImageRequestOptionsResizeMode = .fast,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.sizeMode = sizeMode
        self.resizeMode = resizeMode
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

enum PhotoSizeMode: Equatable {
    
    case resize(CGFloat)
    case preview
    case original
    
    var targetSize: CGSize {
        switch self {
        case .resize(let width):
            return CGSize(width: width, height: width)
        case .preview:
            return UIScreen.main.nativeBounds.size
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}

typealias PhotoFetchResponse = (image: UIImage, isDegraded: Bool)
typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestPhoto(for album: Album, completion: @escaping PhotoFetchCompletion) {
        if let asset = config.orderByDate == .asc ? album.result.lastObject : album.result.firstObject {
            let sacle = UIScreen.main.nativeScale
            let options = PhotoFetchOptions(sizeMode: .resize(55*sacle))
            requestPhoto(for: asset, options: options, completion: completion)
        }
    }
    
    func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = options.resizeMode
        PHImageManager.default().requestImage(for: asset, targetSize: options.sizeMode.targetSize, contentMode: .aspectFill, options: requestOptions) { [unowned self] (image, info) in
            guard let info = info else {
                completion(.failure(.invalidInfo))
                return
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                switch options.sizeMode {
                case .original:
                    completion(.success((image, isDegraded)))
                case .preview:
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
                    if !isDegraded {
                        self.writeCache(image: image, for: asset.localIdentifier)
                    }
                    completion(.success((resizedImage, isDegraded)))
                case .resize:
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
                    completion(.success((resizedImage, isDegraded)))
                }
            } else {
                // Download image from iCloud
                print("Download image from iCloud")
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud && image == nil && options.isNetworkAccessAllowed {
                    let photoDataOptions = PhotoDataFetchOptions(isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                                 progressHandler: options.progressHandler)
                    self.workQueue.async {
                        self.requestPhotoData(for: asset, options: photoDataOptions) { [unowned self] result in
                            switch result {
                            case .success(let response):
                                switch options.sizeMode {
                                case .original:
                                    guard let image = UIImage(data: response.data) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        completion(.success((image, false)))
                                    }
                                case .preview:
                                    let size = self.resize(from: asset.pixelSize, to: options.sizeMode.targetSize)
                                    guard let image = UIImage.resize(from: response.data, size: size) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    self.writeCache(image: image, for: asset.localIdentifier)
                                    DispatchQueue.main.async {
                                        completion(.success((image, false)))
                                    }
                                case .resize:
                                    let size = self.resize(from: asset.pixelSize, to: options.sizeMode.targetSize)
                                    guard let image = UIImage.resize(from: response.data, size: size) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        completion(.success((image, false)))
                                    }
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func resize(from assetSize: CGSize, to targetSize: CGSize) -> CGSize {
        let aspectRatio = assetSize.width / assetSize.height
        var pixelWidth = targetSize.width * aspectRatio
        if aspectRatio > 1.8 {
            pixelWidth = pixelWidth * aspectRatio
        }
        if aspectRatio < 0.2 {
            pixelWidth = pixelWidth * 0.5
        }
        let pixelHeight = pixelWidth / aspectRatio
        return CGSize(width: pixelWidth, height: pixelHeight)
    }
}
