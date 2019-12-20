//
//  VideoEditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol VideoEditorCropToolViewDelegate: class {
    func cropTool(_ view: VideoEditorCropToolView, playButtonTapped button: UIButton)
}

final class VideoEditorCropToolView: UIView {
    
    weak var delegate: VideoEditorCropToolViewDelegate?
    
    private(set) lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "VideoPlayFill"), for: .normal)
        view.setImage(BundleHelper.image(named: "VideoPauseFill"), for: .selected)
        view.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var splitLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    private(set) lazy var progressView: VideoEditorCropProgressView = {
        let view = VideoEditorCropProgressView(frame: .zero)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(playButton)
        addSubview(progressView)
        addSubview(splitLine)
        
        playButton.snp.makeConstraints { (maker) in
            maker.top.left.bottom.equalToSuperview()
            maker.width.equalTo(45)
        }
        splitLine.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(playButton.snp.right)
            maker.width.equalTo(2)
        }
        progressView.snp.makeConstraints { (maker) in
            maker.top.right.bottom.equalToSuperview()
            maker.left.equalTo(splitLine.snp.right)
        }
    }
}

// MARK: - Target
extension VideoEditorCropToolView {
    
    @objc private func playButtonTapped(_ sender: UIButton) {
        delegate?.cropTool(self, playButtonTapped: sender)
    }
}
