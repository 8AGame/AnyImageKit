//
//  PhotoManager.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

final class PhotoManager {
    
    static let shared: PhotoManager = PhotoManager()
    
    var sortAscendingByModificationDate: Bool = true

    private init() { }
}

// MARK: - Album

extension PhotoManager {
    
    func fetchCameraRollAlbum(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: @escaping (Album) -> Void) {
        let options = PHFetchOptions()
        if !allowPickingVideo {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !sortAscendingByModificationDate {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)
            options.sortDescriptors = [sortDescriptor]
        }
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = assetCollectionsFetchResult.objects()
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isCameraRoll {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                let result = Album(result: assetsfetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                completion(result)
            }
        }
    }
    
    func fetchAllAlbums(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: @escaping ([Album]) -> Void) {
        var results = [Album]()
        let options = PHFetchOptions()
        if !allowPickingVideo {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !sortAscendingByModificationDate {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)
            options.sortDescriptors = [sortDescriptor]
        }
        
        let allAlbumSubTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream, .albumRegular, .albumSyncedAlbum, .albumCloudShared]
        let assetCollectionsfetchResults = allAlbumSubTypes.map { PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil) }
        for assetCollectionsFetchResult in assetCollectionsfetchResults {
            let assetCollections = assetCollectionsFetchResult.objects()
            for assetCollection in assetCollections {
                let isCameraRoll = assetCollection.isCameraRoll
                
                if assetCollection.estimatedAssetCount <= 0 && !isCameraRoll { continue }
                
                if assetCollection.isAllHidden { continue }
                if assetCollection.isRecentlyDeleted  { continue }
                
                let assetFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                if assetFetchResult.count <= 0 && !isCameraRoll { continue }
                
                if isCameraRoll {
                    if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                        let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                        results.insert(album, at: 0)
                    }
                } else {
                    if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                        let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: false, needFetchAssets: needFetchAssets)
                        results.append(album)
                    }
                }
            }
        }
        completion(results)
    }
}

// MARK: - Asset

extension PhotoManager {
    
    typealias PhotoFetchHander = (UIImage, [AnyHashable: Any], Bool) -> Void
    
    @discardableResult
    func requestImage(from album: Album, completion: @escaping PhotoFetchHander) -> PHImageRequestID {
        if let asset = album.result.firstObject {
            let sacle = UIScreen.main.nativeScale
            return requestImage(for: asset, width: 55*sacle, completion: completion)
        }
        return PHInvalidImageRequestID
    }
    
    @discardableResult
    func requestImage(for asset: PHAsset, width: CGFloat, isNetworkAccessAllowed: Bool = true, progressHandler: PHAssetImageProgressHandler? = nil, completion: @escaping PhotoFetchHander) -> PHImageRequestID {
        
        let options1 = PHImageRequestOptions()
        options1.resizeMode = .fast
        
        let targetSize = CGSize(width: width, height: width)
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options1) { (image, info) in
            guard let info = info else { return }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                completion(image, info, isDegraded)
            }
            
            // Download image from iCloud
            let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
            if isInCloud && image == nil && isNetworkAccessAllowed {
                let options2 = PHImageRequestOptions()
                options2.progressHandler = progressHandler
                options2.isNetworkAccessAllowed = isNetworkAccessAllowed
                options2.resizeMode = .fast
                PHImageManager.default().requestImageData(for: asset, options: options2) { (data, uti, orientation, info) in
                    if let data = data, let info = info, let image = UIImage.resize(from: data, size: targetSize) {
                        completion(image, info, false)
                    }
                }
            }
        }
        return imageRequestID
    }
}
