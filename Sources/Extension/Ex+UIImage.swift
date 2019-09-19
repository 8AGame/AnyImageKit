//
//  UIImage.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    
    static func resize(from image: UIImage, size: CGSize) -> UIImage {
        if image.size.width <= size.width { return image }
        if image.size.height <= size.height { return image }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func resize(from data: Data, size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]

        guard
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
            else {
                return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
