//
//  Album.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation
import Photos

class Album {
    
    let id: String
    let name: String
    let isCameraRoll: Bool
    let result: PHFetchResult<PHAsset>
    private(set) var assets: [Asset] = []
    
    init(result: PHFetchResult<PHAsset>, id: String, name: String?, isCameraRoll: Bool, needFetchAssets: Bool) {
        self.id = id
        self.name = name ?? ""
        self.isCameraRoll = isCameraRoll
        self.result = result
        if needFetchAssets {
            fetchAssets()
        }
    }
}

extension Album {
    
    var count: Int {
        return result.count
    }
}

extension Album {
    
    func fetchAssets() {
        assets = result.objects().map { Asset(asset: $0, type: $0.mediaType) }
    }
}

extension Album: CustomStringConvertible {
    
    var description: String {
        return "Album<\(name)>"
    }
}
