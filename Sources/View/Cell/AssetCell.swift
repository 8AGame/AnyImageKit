//
//  AssetCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class AssetCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var gifView: GIFView = {
        let view = GIFView()
        view.isHidden = true
        return view
    }()
    private lazy var videoView: VideoView = {
        let view = VideoView()
        view.isHidden = true
        return view
    }()
    private lazy var selectdCoverView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    private lazy var disableCoverView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    private(set) lazy var boxCoverView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.borderWidth = 4
        view.layer.borderColor = PhotoManager.shared.config.theme.mainColor.cgColor
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .default)
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectdCoverView.isHidden = true
        gifView.isHidden = true
        videoView.isHidden = true
        disableCoverView.isHidden = true
        boxCoverView.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(selectdCoverView)
        addSubview(gifView)
        addSubview(videoView)
        addSubview(disableCoverView)
        addSubview(boxCoverView)
        addSubview(selectButton)
        
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectdCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        gifView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        videoView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        disableCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        boxCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints { maker in
            maker.top.right.equalToSuperview().inset(3)
            maker.width.height.equalTo(30)
        }
    }
}

extension AssetCell {
    
    var image: UIImage? {
        return imageView.image
    }
}

extension AssetCell {
    
    func setContent(_ asset: Asset, animated: Bool = false, isPreview: Bool = false) {
        let options = PhotoFetchOptions(sizeMode: .resize(100*UIScreen.main.nativeScale), needCache: false)
        PhotoManager.shared.requestPhoto(for: asset.phAsset, options: options, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.imageView.image = response.image
                if asset.mediaType == .video && !isPreview {
                    self.videoView.setVideoTime(asset.videoDuration)
                }
            case .failure(let error):
                _print(error)
            }
        })
        
        updateState(asset, animated: animated, isPreview: isPreview)
    }
    
    func updateState(_ asset: Asset, animated: Bool = false, isPreview: Bool = false) {
        switch asset.mediaType {
        case .photoGIF:
            gifView.isHidden = false
        case .video:
            videoView.isHidden = false
        default:
            break
        }
        
        if !isPreview {
            selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: animated)
            selectdCoverView.isHidden = !asset.isSelected
            disableCoverView.isHidden = !(PhotoManager.shared.isUpToLimit && !asset.isSelected)
        }
    }
}
