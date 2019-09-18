//
//  PhotoPreviewNavigationBar.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoPreviewNavigationBar: UIView {

    private(set) lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "ReturnButtonWhite"), for: .normal)
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(style: .large)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hex: 0x2E2E2E).withAlphaComponent(0.95)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let contentView = UILayoutGuide()
        addLayoutGuide(contentView)
        addSubview(backButton)
        addSubview(selectButton)
        contentView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(44)
        }
        backButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalTo(contentView)
            maker.height.equalTo(44)
        }
        selectButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-8)
            maker.centerY.equalTo(contentView)
            maker.width.height.equalTo(35)
        }
    }

}
