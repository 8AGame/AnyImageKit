//
//  HUDHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/21.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

private var hudWindow: UIWindow?
private var _hud: HUDViewController?
private var hud: HUDViewController? {
    if _hud == nil {
        _hud = HUDViewController()
    }
    return _hud
}


func showWaitHUD() {
    createHUDWindowIfNeeded()
    hud?.wait()
}

func showMessageHUD(_ message: String) {
    createHUDWindowIfNeeded()
    hud?.show(message: message)
}

func hideHUD() {
    hud?.hide()
}

private func createHUDWindowIfNeeded() {
    if hudWindow == nil {
        let window = UIWindow(frame: ScreenHelper.mainBounds)
        window.alpha = 1
        window.isHidden = false
        window.windowLevel = .alert
        window.rootViewController = hud
        hud?.hudDidHide = {
            hudWindow = nil
            _hud = nil
        }
        hudWindow = window
    }
}
