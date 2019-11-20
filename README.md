![AnyImageKit](./Resources/TitleMap@2x.png)

[![Travis CI](https://api.travis-ci.org/AnyImageProject/AnyImageKit.svg?branch=master)](https://travis-ci.com/AnyImageProject/AnyImageKit)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AnyImageKit.svg)](https://img.shields.io/cocoapods/v/AnyImageKit.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/AnyImageKit.svg?style=flat)](./)
[![License](https://img.shields.io/cocoapods/l/AnyImageKit.svg?style=flat)](https://raw.githubusercontent.com/AnyImageProject/AnyImageKit/master/LICENSE)

`AnyImageKit` is a toolbox for picking and editing photos. It's written in Swift. 

> [中文说明](./README_CN.md)

## Features

- [x] Light mode, dark mode or auto mode support
- [x] Default theme is similar with Wechat 
- [x] Multiple & mix select support
- [x] Supported media types:
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] Camera
- [x] Edit image ( Technical Preview )
    - [x] Drawing
    - [ ] Emoji
    - [ ] Input text
    - [x] Cropping
    - [x] Mosaic
- [ ] Multiple platform support
    - [x] iOS
    - [x] iPadOS ( Not support in editor )
    - [x] Mac Catalyst ( Technical Preview, Not support in editor )
    - [ ] macOS
    - [ ] tvOS

## Requirements

- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add this to `Podfile`, and then update dependency:

```ruby
pod 'AnyImageKit'
```

### [Carthage](https://github.com/Carthage/Carthage)

Add this to `Cartfile`, and then update dependency:

```ogdl
github "AnyImageProject/AnyImageKit"
```

> Unsupport `--no-use-binaries`

## Usage

### Quick Start

```swift
import AnyImageKit

let controller = ImagePickerController(delegate: self)
present(controller, animated: true, completion: nil)

/// ImagePickerControllerDelegate
func imagePickerDidCancel(_ picker: ImagePickerController) {
    // Your code, handle cancel
    picker.dismiss(animated: true, completion: nil)
}
    
func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool) {
    // Your code, handle select assets
    let images = assets.map { $0.image }
    picker.dismiss(animated: true, completion: nil)
}
```

### Fetch content data
```swift
/// Fetch Video URL 
/// - Note: Only for `MediaType` Video
/// - Parameter options: Video URL Fetch Options
/// - Parameter completion: Video URL Fetch Completion
func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion)

// Call
asset.fetchVideoURL { (result) in
    // Your code
}
```

## License

AnyImageKit is released under the MIT license. See [LICENSE](./LICENSE) for details.
