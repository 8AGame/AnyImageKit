//
//  CaptureOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVFoundation

public struct CaptureOptionsInfo: Equatable {
    
    /// 主题色
    /// 默认：绿色 0x57BE6A
    public var tintColor: UIColor = UIColor.color(hex: 0x57BE6A)
    
    /// 媒体类型
    /// 默认：Photo+Video
    public var mediaOptions: CaptureMediaOption = [.photo, .video]
    
    /// 照片拍摄比例
    /// 默认：4:3
    public var photoAspectRatio: CaptureAspectRatio = .ratio4x3
    
    /// 使用的摄像头
    /// 默认：后置+前置
    public var preferredPositions: [CapturePosition] = [.back, .front]
    
    /// 默认闪光灯模式
    /// 默认：关闭
    public var flashMode: CaptureFlashMode = .off
    
    /// 视频拍摄最大时间
    /// 默认 20 秒
    public var videoMaximumDuration: TimeInterval = 20
    
    /// 相机预设
    /// 默认支持从 1920*1080@60 开始查找支持的最佳分辨率
    public var preferredPreset: [CapturePreset] = CapturePreset.createPresets(enableHighResolution: false, enableHighFrameRate: true)
    
    /// 启用调试日志
    /// 默认：false
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    public var editorPhotoOptions: EditorPhotoOptionsInfo = .init()
    public var editorVideoOptions: EditorVideoOptionsInfo = .init()
    #endif
    
    public init() { }
}

public struct CaptureMediaOption: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let photo = CaptureMediaOption(rawValue: 1 << 0)
    
    public static let video = CaptureMediaOption(rawValue: 1 << 1)
}

extension CaptureMediaOption {
    
    var localizedTips: String {
        if contains(.photo) && contains(.video) {
            return BundleHelper.captureLocalizedString(key: "Tap to take photo and hode to record video")
        }
        if contains(.photo) {
            return BundleHelper.captureLocalizedString(key: "Tap to take photo")
        }
        if contains(.video) {
            return BundleHelper.captureLocalizedString(key: "Hode to record video")
        }
        return ""
    }
}

public enum CaptureAspectRatio: Equatable {
    
    case ratio1x1
    case ratio4x3
    case ratio16x9
    
    var value: Double {
        switch self {
        case .ratio1x1:
            return 1.0/1.0
        case .ratio4x3:
            return 3.0/4.0
        case .ratio16x9:
            return 9.0/16.0
        }
    }
    
    var cropValue: CGFloat {
        switch self {
        case .ratio1x1:
            return 9.0/16.0
        case .ratio4x3:
            return 3.0/4.0
        case .ratio16x9:
            return 1.0/1.0
        }
    }
}
