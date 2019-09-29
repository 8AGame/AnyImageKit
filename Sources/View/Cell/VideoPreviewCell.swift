//
//  VideoPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import MediaPlayer

final class VideoPreviewCell: PreviewCell {
    
    public var isPlaying: Bool {
        player
    }
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "VideoPlay"), for: .normal)
        view.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
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
        imageView.removeFromSuperview()
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleToFill
        scrollView.addSubview(imageView)
    }
    
    override func layout() {
        super.layout()
        playerLayer?.frame = fitFrame
    }
}

// MARK: - Public function
extension VideoPreviewCell {
    
    public func setPlayerItem(_ item: AVPlayerItem) {
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        scrollView.layer.addSublayer(playerLayer!)
    }
    
}

// MARK: - Action
extension VideoPreviewCell {
    
    @objc private func playButtonTapped(_ sender: UIButton) {
        
    }
}
