//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageEditorControllerDelegate: class {
    
    func imageEditorDidFinishEdit(_ controller: ImageEditorController, photo: UIImage)
}

open class ImageEditorController: UINavigationController {
    
    open weak var editorDelegate: ImageEditorControllerDelegate?
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    required public init(image: UIImage, config: PhotoConfig = PhotoConfig(), delegate: ImageEditorControllerDelegate) {
        EditorManager.shared.image = image
        EditorManager.shared.photoConfig = config
        let rootViewController = PhotoEditorController()
        super.init(rootViewController: rootViewController)
        rootViewController.delegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PhotoEditorControllerDelegate
extension ImageEditorController: PhotoEditorControllerDelegate {
    
    func photoEditorDidFinishEdit(_ controller: PhotoEditorController, photo: UIImage) {
        editorDelegate?.imageEditorDidFinishEdit(self, photo: photo)
    }
}
