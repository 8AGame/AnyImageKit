//
//  BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

struct BundleHelper {
    
    static private var _languageBundle: Bundle?
    
    static var languageBundle: Bundle? {
        if _languageBundle == nil {
            var language = Locale.preferredLanguages.first ?? "en"
            if language.hasPrefix("zh") {
                if language.contains("Hans") {
                    language = "zh-Hans"
                } else {
                    language = "zh-Hant"
                }
            }
            _languageBundle = Bundle(path: Bundle.current.path(forResource: language, ofType: "lproj") ?? "")
        }
        return _languageBundle
    }
}

// MARK: - Info
extension BundleHelper {
    
    static var appName: String {
        if let info = Bundle.main.localizedInfoDictionary {
            if let appName = info["CFBundleDisplayName"] as? String { return appName }
            if let appName = info["CFBundleName"] as? String { return appName }
            if let appName = info["CFBundleExecutable"] as? String { return appName }
        }
        
        if let info = Bundle.main.infoDictionary {
            if let appName = info["CFBundleDisplayName"] as? String { return appName }
            if let appName = info["CFBundleName"] as? String { return appName }
            if let appName = info["CFBundleExecutable"] as? String { return appName }
        }
        return ""
    }
}

// MARK: - Styled Image
extension BundleHelper {
    
    static func image(named: String) -> UIImage? {
        return UIImage(named: named, in: .current, compatibleWith: nil)
    }
    
    static func image(named: String, style: UserInterfaceStyle) -> UIImage? {
        let imageName: String
        switch style {
        case .auto:
            imageName = named + "Auto"
        case .light:
            imageName = named + "Light"
        case .dark:
            imageName = named + "Dark"
        }
        return UIImage(named: imageName, in: .current, compatibleWith: nil)
    }
}

// MARK: - Localized String
extension BundleHelper {
    
    static func localizedString(key: String, value: String?, table: String) -> String {
        if let result = languageBundle?.localizedString(forKey: key, value: value, table: table), result != key {
            return result
        } else if table != "Core", let result = languageBundle?.localizedString(forKey: key, value: value, table: table), result != key {
            return result
        }
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    
    static func coreLocalizedString(key: String) -> String {
        localizedString(key: key, value: nil, table: "Core")
    }
    
    #if ANYIMAGEKIT_ENABLE_PICKER
    static func pickerLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: "Picker")
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    static func editorLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: "Editor")
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    static func captureLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: "Capture")
    }
    #endif
}
