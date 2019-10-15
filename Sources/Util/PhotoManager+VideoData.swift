//
//  PhotoManager+VideoData.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/10/15.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import AVFoundation

enum VideoDataExportPreset: RawRepresentable {
    /// H.264/AVC 640x480
    case h264_640x480
    /// H.264/AVC 960x540
    case h264_960x540
    /// H.264/AVC 1280x720
    case h264_1280x720
    /// H.264/AVC 1920x1080
    case h264_1920x1080
    /// H.264/AVC 3840x2160
    case h264_3840x2160
    
    /// H.265/HEVC 3840x2160 when < iOS 11 = h264_1920x1080
    case h265_1920x1080
    /// H.265/HEVC 3840x2160 when < iOS 11 = h264_3840x2160
    case h265_3840x2160
    
    var rawValue: String {
        switch self {
        case .h264_640x480:
            return AVAssetExportPreset640x480
        case .h264_960x540:
            return AVAssetExportPreset960x540
        case .h264_1280x720:
            return AVAssetExportPreset1280x720
        case .h264_1920x1080:
            return AVAssetExportPreset1920x1080
        case .h264_3840x2160:
            return AVAssetExportPreset3840x2160
        case .h265_1920x1080:
            if #available(iOS 11.0, *) {
                return AVAssetExportPresetHEVC1920x1080
            } else {
                return AVAssetExportPreset1920x1080
            }
        case .h265_3840x2160:
            if #available(iOS 11.0, *) {
                return AVAssetExportPresetHEVC3840x2160
            } else {
                return AVAssetExportPreset3840x2160
            }
        }
    }
    
    init?(rawValue: String) {
        if #available(iOS 11.0, *) {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            case AVAssetExportPresetHEVC1920x1080:
                self = .h265_1920x1080
            case AVAssetExportPresetHEVC3840x2160:
                self = .h265_3840x2160
            default:
                return nil
            }
        } else {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            default:
                return nil
            }
        }
    }
}

struct VideoDataFetchOptions {
    
    let isNetworkAccessAllowed: Bool
    let version: PHVideoRequestOptionsVersion
    let deliveryMode: PHVideoRequestOptionsDeliveryMode
    let progressHandler: PHAssetVideoProgressHandler?
    let exportPreset: VideoDataExportPreset
    
    init(isNetworkAccessAllowed: Bool = true,
         version: PHVideoRequestOptionsVersion = .current,
         deliveryMode: PHVideoRequestOptionsDeliveryMode = .automatic,
         progressHandler: PHAssetVideoProgressHandler? = nil,
         exportPreset: VideoDataExportPreset = .h264_1280x720) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.deliveryMode = deliveryMode
        self.progressHandler = progressHandler
        self.exportPreset = exportPreset
    }
}

struct VideoDataFetchResponse {
    
    let outputURL: URL
}

typealias VideoDataFetchCompletion = (Result<VideoDataFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func fetchVideoData(for asset: PHAsset, options: VideoDataFetchOptions = .init(), completion: @escaping VideoDataFetchCompletion) {
        let supportPresets = AVAssetExportSession.allExportPresets()
        guard supportPresets.contains(options.exportPreset.rawValue) else {
            completion(.failure(.invalidExportPreset))
            return
        }
        
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.version = options.version
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.progressHandler
        
        PHImageManager.default().requestExportSession(forVideo: asset, options: requestOptions, exportPreset: options.exportPreset.rawValue) { [weak self] (exportSession, info) in
            guard let self = self else { return }
            if let exportSession = exportSession {
                self.exportVideoData(for: exportSession, options: options, completion: completion)
            } else {
                completion(.failure(.invalidExportSession))
            }
        }
    }
    
    private func exportVideoData(for exportSession: AVAssetExportSession, options: VideoDataFetchOptions, completion: @escaping VideoDataFetchCompletion) {
        let tmpPath = NSHomeDirectory().appending("/tmp")
        if !FileManager.default.fileExists(atPath: tmpPath) {
            do {
                try FileManager.default.createDirectory(atPath: tmpPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completion(.failure(.createDirectory))
                return
            }
        }
        
        let supportedFileTypes = exportSession.supportedFileTypes
        guard supportedFileTypes.contains(.mp4) else {
            completion(.failure(.invalidFileType))
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HH:mm:ss"
        let outputPath = tmpPath.appending("/video-\(formatter.string(from: Date())).mp4")
        let outputURL = URL(fileURLWithPath: outputPath)
        
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .unknown:
                    print("unknown")
                case .waiting:
                    print("waiting")
                case .exporting:
                    print("exporting")
                case .completed:
                    completion(.success(VideoDataFetchResponse(outputURL: outputURL)))
                case .failed:
                    completion(.failure(.exportFail))
                case .cancelled:
                    print("cancelled")
                @unknown default:
                    break
                }
            }
        }
    }
}
