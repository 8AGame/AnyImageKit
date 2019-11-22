//
//  OriginalButton.swift
//  UI
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 RayJiang. All rights reserved.
//

import UIKit

final class OriginalButton: UIControl {
    
    override var isSelected: Bool {
        didSet {
            circleView.isSelected = isSelected
        }
    }
    
    private lazy var circleView: CircleView = {
        let view = CircleView(frame: .zero, config: config)
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.pickerLocalizedString(key: "Original image")
        view.textColor = config.theme.textColor
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private let config: ImagePickerController.Config
    
    init(frame: CGRect, config: ImagePickerController.Config) {
        self.config = config
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(circleView)
        addSubview(label)
        circleView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(self).multipliedBy(0.6)
            maker.width.equalTo(circleView.snp.height)
        }
        label.snp.makeConstraints { maker in
            maker.left.equalTo(circleView.snp.right).offset(5)
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
        circleView.isSelected = isSelected
    }
}

fileprivate class CircleView: UIView {
    
    var isSelected = false {
        didSet {
            smallCircleView.isHidden = !isSelected
        }
    }
    
    private lazy var bigCircleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = config.theme.textColor.cgColor
        return view
    }()
    private lazy var smallCircleView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.clipsToBounds = true
        view.backgroundColor = config.theme.mainColor
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bigCircleView.layer.cornerRadius = bounds.width * 0.5
        smallCircleView.layer.cornerRadius = bounds.width * 0.5 - 3
    }
    
    private let config: ImagePickerController.Config
    
    init(frame: CGRect, config: ImagePickerController.Config) {
        self.config = config
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(bigCircleView)
        addSubview(smallCircleView)
        bigCircleView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        smallCircleView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(3)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13, *) {
            guard config.theme.style == .auto else { return }
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            bigCircleView.layer.borderColor = config.theme.textColor.cgColor
        }
    }
    
}
