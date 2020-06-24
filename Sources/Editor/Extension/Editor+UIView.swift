//
// Editor+UIView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/5.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

extension UIView {
    
    func screenshot(_ imageSize: CGSize = .zero) -> UIImage {
        let size = CGSize(width: self.bounds.size.width.roundTo(places: 5), height: self.bounds.size.height.roundTo(places: 5))
        let renderer: UIGraphicsImageRenderer
        if imageSize == .zero {
            renderer = UIGraphicsImageRenderer(size: size)
        } else {
            let format = UIGraphicsImageRendererFormat()
            format.scale = imageSize.width / size.width
            renderer = UIGraphicsImageRenderer(size: size, format: format)
        }
        #if swift(>=5.3)
        return renderer.image { [self] (context) in
            return layer.render(in: context.cgContext)
        }
        #else
        return renderer.image { [weak self] (context) in
            return self?.layer.render(in: context.cgContext)
        }
        #endif
    }
}
