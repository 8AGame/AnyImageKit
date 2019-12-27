//
//  CapturePreviewMaskView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/10.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class CapturePreviewMaskView: UIView {
    
    var maskColor: UIColor = UIColor.black.withAlphaComponent(0.25) {
        didSet { updateMaskColor() }
    }
    
    private(set) lazy var topMaskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = maskColor
        return view
    }()
    
    private lazy var centerLayoutGuide: UILayoutGuide = {
        let layoutGuide = UILayoutGuide()
        return layoutGuide
    }()
    
    private(set) lazy var bottomMaskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = maskColor
        return view
    }()
    
    private let config: AnyImageCaptureOptionsInfo
    
    init(frame: CGRect, config: AnyImageCaptureOptionsInfo) {
        self.config = config
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addLayoutGuide(centerLayoutGuide)
        addSubview(topMaskView)
        addSubview(bottomMaskView)
        topMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(snp.top)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
        }
        centerLayoutGuide.snp.makeConstraints { maker in
            maker.top.equalTo(topMaskView.snp.bottom)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
            maker.width.equalTo(centerLayoutGuide.snp.height).multipliedBy(config.photoAspectRatio.value)
        }
        bottomMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(centerLayoutGuide.snp.bottom)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
            maker.bottom.equalTo(snp.bottom)
            maker.height.equalTo(topMaskView.snp.height)
        }
    }
    
    private func updateMaskColor() {
        topMaskView.backgroundColor = maskColor
        bottomMaskView.backgroundColor = maskColor
    }
}
