//
//  ScalePresentationController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class ScalePresentationController: UIPresentationController {
    
    var maskAlpha: CGFloat {
        get {
            return maskView.alpha
        } set {
            maskView.alpha = newValue
        }
    }
    
    /// 蒙板
    private(set) var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorHelper.createByStyle(light: .white, dark: .black)
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = self.containerView else { return }
        
        containerView.addSubview(maskView)
        maskView.frame = containerView.bounds
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.maskView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.maskView.alpha = 0
        })
    }
}
