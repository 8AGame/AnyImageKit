//
//  PhotoPreviewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

final class PhotoPreviewController: UIViewController {

    public weak var delegate: PhotoPreviewControllerDelegate? = nil
    public weak var dataSource: PhotoPreviewControllerDataSource? = nil
    
    /// 图片索引
    public var currentIndex: Int = 0 {
        didSet {
            didSetCurrentIdx()
        }
    }
    /// 左右两张图之间的间隙
    public var photoSpacing: CGFloat = 30
    /// 图片缩放模式
    public var imageScaleMode: UIView.ContentMode = .scaleAspectFill
    /// 捏合手势放大图片时的最大允许比例
    public var imageMaximumZoomScale: CGFloat = 2.0
    /// 双击放大图片时的目标比例
    public var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    // MARK: - Private
    
    /// 是否使用原图
    private var useOriginalPhoto: Bool = false
    /// 当前正在显示视图的前一个页面关联视图
    private var relatedView: UIView? {
        return dataSource?.previewController(self, thumbnailViewForIndex: currentIndex)
    }
    /// 缩放型转场协调器
    private weak var scalePresentationController: ScalePresentationController?
    /// 保存原windowLevel
    private lazy var originWindowLevel: UIWindow.Level? = { [weak self] in
        let window = self?.view.window ?? UIApplication.shared.keyWindow
        return window?.windowLevel
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(PhotoPreviewCell.self)
        collectionView.registerCell(VideoPreviewCell.self)
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()
    private lazy var navigationBar: PhotoPreviewNavigationBar = {
        let view = PhotoPreviewNavigationBar()
        view.backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var toolBar: PhotoPreviewToolBar = {
        let view = PhotoPreviewToolBar()
        view.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.addTarget(self, action: #selector(originalButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coverStatusBar(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBar(hidden: false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coverStatusBar(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    @available(iOS 11.0, *)
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

// MARK: - Private function
extension PhotoPreviewController {
    /// 添加视图
    private func setupViews() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        view.addSubview(navigationBar)
        view.addSubview(toolBar)
        setupLayout()
        setBar(hidden: true, animated: false)
        
        // TODO: 单击和双击有冲突
//        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
//        collectionView.addGestureRecognizer(singleTap)
    }

//    @objc private func onSingleTap() {
//        setBar(hidden: navigationBar.alpha == 1, animated: false)
//    }
    
    /// 设置视图布局
    private func setupLayout() {
        navigationBar.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                maker.height.equalTo(64)
            }
        }
        toolBar.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            } else {
                maker.height.equalTo(50)
            }
        }
    }
    
    /// 更新视图布局
    private func updateLayout() {
        flowLayout.minimumLineSpacing = photoSpacing
        flowLayout.itemSize = UIScreen.main.bounds.size
        collectionView.frame = view.bounds
        collectionView.frame.size.width = view.bounds.width + photoSpacing
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: photoSpacing)
    }
    
    private func setBar(hidden: Bool, animated: Bool = true) {
        if navigationBar.alpha == 0 && hidden { return }
        if navigationBar.alpha == 1 && !hidden { return }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.navigationBar.alpha = hidden ? 0 : 1
                self.toolBar.alpha = hidden ? 0 : 1
            }
        } else {
            navigationBar.alpha = hidden ? 0 : 1
            toolBar.alpha = hidden ? 0 : 1
        }
    }
    
    /// 遮盖状态栏。以改变 windowLevel 的方式遮盖
    /// - parameter cover: true-遮盖；false-不遮盖
    private func coverStatusBar(_ cover: Bool) {
        guard let window = view.window ?? UIApplication.shared.keyWindow else {
            return
        }
        if originWindowLevel == nil {
            originWindowLevel = window.windowLevel
        }
        guard let originLevel = originWindowLevel else {
            return
        }
        window.windowLevel = cover ? UIWindow.Level.statusBar + 1 : originLevel
    }
    
    private func didSetCurrentIdx() {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        // TODO:
        navigationBar.selectButton.isEnabled = true
        navigationBar.selectButton.setNum(1, isSelected: data.asset.isSelected, animated: false)
        toolBar.hiddenEditAndOriginalButton(data.asset.type != .photo)
    }
}

// MARK: - Target
extension PhotoPreviewController {
    
    /// NavigationBar - Back
    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// NavigationBar - Select
    @objc private func selectButtonTapped(_ sender: UIButton) {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        sender.isSelected.toggle()
        data.asset.isSelected = sender.isSelected
        // TODO:
        navigationBar.selectButton.setNum(1, isSelected: data.asset.isSelected, animated: true)
        // TODO: select 状态已经更改，是否还有必要使用使用 delegate
        if sender.isSelected {
            delegate?.previewController(self, didSelected: currentIndex)
        } else {
            delegate?.previewController(self, didDeselected: currentIndex)
        }
    }
    
    /// ToolBar - Edit
    @objc private func editButtonTapped(_ sender: UIButton) {
        guard let cell = collectionView.visibleCells.first as? PhotoPreviewCell else { return }
        let vc = PhotoEditViewController()
        vc.imageView.image = cell.imageView.image
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    /// ToolBar - Original
    @objc private func originalButtonTapped(_ sender: UIButton) {
        
    }
    
    /// ToolBar - Done
    @objc private func doneButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoPreviewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoPreviewCell else { return }
        cell.reset()
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoPreviewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPhotos(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoPreviewCell.self, for: indexPath)
        cell.imageView.contentMode = imageScaleMode
        cell.delegate = self
        cell.imageMaximumZoomScale = imageMaximumZoomScale
        cell.imageZoomScaleForDoubleTap = imageZoomScaleForDoubleTap
        
        // 加载图片
        if let data = dataSource?.previewController(self, assetOfIndex: indexPath.row) {
            cell.setImage(data.thumbnail)
            PhotoManager.shared.requestImage(for: data.asset.asset, width: 2000) { (image, _, _) in
                cell.setImage(image)
            }
        }
        return cell
    }
}

extension PhotoPreviewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var idx = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let x = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width)
        if x > scrollView.bounds.width / 2 {
            idx += 1
        }
        if idx != currentIndex {
            currentIndex = idx
        }
    }
}

// MARK: - PhotoPreviewCellDelegate
extension PhotoPreviewController: PhotoPreviewCellDelegate {
    
    func previewCell(_ cell: PhotoPreviewCell, didPanScale scale: CGFloat) {
        // 实测用 scale 的平方，效果比线性好些
        let alpha = scale * scale
        scalePresentationController?.maskAlpha = alpha
        setBar(hidden: true)
    }
    
    func previewCell(_ cell: PhotoPreviewCell, didEndPanWithExit isExit: Bool) {
        if isExit {
            dismiss(animated: true, completion: nil)
        } else {
            setBar(hidden: false)
        }
    }
    
    func previewCellDidSingleTap(_ cell: PhotoPreviewCell) {
        setBar(hidden: navigationBar.alpha == 1, animated: false)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PhotoPreviewController: UIViewControllerTransitioningDelegate {
    /// 提供进场动画
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        updateLayout()
        // 立即加载collectionView
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        collectionView.layoutIfNeeded()
        return makeScalePresentationAnimator(indexPath: indexPath)
    }

    /// 提供退场动画
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makeDismissedAnimator()
    }

    /// 提供转场协调器
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ScalePresentationController(presentedViewController: presented, presenting: presenting)
        scalePresentationController = controller
        return controller
    }

    /// 创建缩放型进场动画
    private func makeScalePresentationAnimator(indexPath: IndexPath) -> UIViewControllerAnimatedTransitioning {
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoPreviewCell
        let imageView = UIImageView(image: cell?.imageView.image)
        imageView.contentMode = imageScaleMode
        imageView.clipsToBounds = true
        // 创建animator
        return ScaleAnimator(startView: relatedView, endView: cell?.imageView, scaleView: imageView)
    }

    /// 创建缩放型退场动画
    private func makeDismissedAnimator() -> UIViewControllerAnimatedTransitioning? {
        guard let cell = collectionView.visibleCells.first as? PhotoPreviewCell else {
            return nil
        }
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = imageScaleMode
        imageView.clipsToBounds = true
        return ScaleAnimator(startView: cell.imageView, endView: relatedView, scaleView: imageView)
    }
}
