//
//  AssetPickerViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import SwiftUI
import UIKit

private let defaultAssetSpacing: CGFloat = 8
private let toolBarHeight: CGFloat = 56

// MARK: - AssetPickerViewControllerDelegate

protocol AssetPickerViewControllerDelegate: AnyObject {
  func assetPickerDidCancel(_ picker: AssetPickerViewController)
  func assetPickerDidFinishPicking(_ picker: AssetPickerViewController)
}

extension UIVisualEffectView {
  static func glassView(
    cornerRadius: CGFloat = 0,
    masksToBounds: Bool = false,
    boundArray _: [UIView.AutoresizingMask] = [.flexibleWidth, .flexibleHeight])
    -> UIVisualEffectView
  {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    view.saturationAmount = 2.2
    view.gaussianBlurRadius = 36
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = masksToBounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return view
  }
}

extension UIImage {
  static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.colors = colors.map(\.cgColor)

    // This makes it left to right, default is top to bottom
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

    let renderer = UIGraphicsImageRenderer(bounds: bounds)

    return renderer.image { ctx in
      gradientLayer.render(in: ctx.cgContext)
    }
  }
}

// MARK: - AssetPickerViewController

final class AssetPickerViewController: AnyImageViewController {
  weak var delegate: AssetPickerViewControllerDelegate?

  private(set) var albumsPicker: AlbumPickerViewController?
  private(set) var album: Album?
  private(set) var albums = [Album]()

  private var preferredCollectionWidth: CGFloat = .zero
  private var autoScrollToLatest = false
  private var didRegisterPhotoLibraryChangeObserver = false
  private var containerSize: CGSize = ScreenHelper.mainBounds.size

  #if swift(>=5.5)
  private var _dataSource: Any?
  @available(iOS 14.0, *)
  private var dataSource: UICollectionViewDiffableDataSource<Section, Asset> {
    get {
      if _dataSource == nil {
        _dataSource = UICollectionViewDiffableDataSource<
          Section,
          Asset
        >(collectionView: collectionView) { _, _, _ -> UICollectionViewCell? in
          nil
        }
      }
      return _dataSource as! UICollectionViewDiffableDataSource<Section, Asset>
    }
    set {
      _dataSource = newValue
    }
  }
  #else
  @available(iOS 14.0, *)
  private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Asset>()
  #endif

  lazy var stopReloadAlbum = false

  private lazy var titleView: PickerArrowButton = {
    let view = PickerArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
    view.addTarget(self, action: #selector(titleViewTapped(_:)), for: .touchUpInside)
    return view
  }()

  private(set) lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = defaultAssetSpacing
    layout.minimumInteritemSpacing = defaultAssetSpacing
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.alwaysBounceVertical = true
    view.contentInsetAdjustmentBehavior = .automatic

    view.contentInset = UIEdgeInsets(
      top: defaultAssetSpacing,
      left: defaultAssetSpacing * 2,
      bottom: defaultAssetSpacing,
      right: defaultAssetSpacing * 2)
    // 컬렉션뷰 배경 색상
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    manager.options.theme[color: .background]
    if #available(iOS 14.0, *) {
    } else {
      view.registerCell(AssetCell.self)
      view.dataSource = self
    }
    view.delegate = self
    return view
  }()

  private(set) lazy var toolBar: PickerToolBar = {
    let view = PickerToolBar(style: .picker)
    view.setEnable(false)
    view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
    view.originalButton.isSelected = manager.useOriginalImage
    view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
    view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    view.permissionLimitedView.limitedButton.addTarget(
      self,
      action: #selector(limitedButtonTapped(_:)),
      for: .touchUpInside)
    return view
  }()

  private lazy var permissionView: PermissionDeniedView = {
    let view = PermissionDeniedView(frame: .zero)
    view.isHidden = true
    return view
  }()

  private var itemOffset: Int {
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    switch manager.options.orderByDate {
    case .asc:
      return 0
    case .desc:
      guard !manager.options.captureOptions.mediaOptions.isEmpty else { return 0 }
      return (album?.hasCamera ?? false) ? 1 : 0
    }
    #else
    return 0
    #endif
  }

  private weak var previewController: PhotoPreviewController?

  let manager: PickerManager

  init(manager: PickerManager) {
    self.manager = manager
    super.init(nibName: nil, bundle: nil)
  }

  deinit {
    unregisterPhotoLibraryChangeObserver()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addNotifications()
    setupView()
    setupNavigation()
    if #available(iOS 14.0, *) {
      setupDataSource()
    }
    checkPermission()
    update(options: manager.options)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if autoScrollToLatest {
      scrollToEnd()
      autoScrollToLatest = false
    }
  }

  private func setupNavigation() {
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    navigationController?.navigationBar.layer.cornerRadius = 20
    navigationController?.navigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    navigationController?.navigationBar.layer.masksToBounds = true
    navigationItem.titleView = titleView
    navigationItem.titleView?.tintColor = .white
    //    navigationItem.titleView?.tintColor = .white

    let cancel = UIBarButtonItem(
      title: manager.options.theme[string: .cancel],
      style: .plain,
      target: self,
      action: #selector(cancelButtonTapped(_:)))
    navigationItem.rightBarButtonItem = cancel
    navigationItem.rightBarButtonItem?.tintColor = .white
  }

  private func setupView() {
    let backgroundBlurView = UIVisualEffectView.glassView(
      cornerRadius: 20,
      masksToBounds: true,
      boundArray: [.flexibleWidth, .flexibleHeight])
    view.addSubview(backgroundBlurView)
    view.addSubview(collectionView)
    view.addSubview(permissionView)
    backgroundBlurView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    collectionView.snp.makeConstraints { maker in
      maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      maker.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      maker.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(50)
    }
    permissionView.snp.makeConstraints { maker in
      if #available(iOS 11.0, *) {
        maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      } else {
        maker.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
      }
      maker.left.right.bottom.equalToSuperview()
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    UIStatusBarStyle(style: manager.options.theme.style)
  }
}

// MARK: PickerOptionsConfigurable

extension AssetPickerViewController: PickerOptionsConfigurable {
  var childrenConfigurable: [PickerOptionsConfigurable] {
    preferredChildrenConfigurable + [titleView]
  }
}

// MARK: - Private function

extension AssetPickerViewController {
  /// After iOS 15.2/Xcode 13.2, you must register PhotoLibraryChangeObserver after authorized Photo permission
  private func registerPhotoLibraryChangeObserver() {
    guard !didRegisterPhotoLibraryChangeObserver else { return }
    PHPhotoLibrary.shared().register(self)
    didRegisterPhotoLibraryChangeObserver = true
  }

  private func unregisterPhotoLibraryChangeObserver() {
    guard didRegisterPhotoLibraryChangeObserver else { return }
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
    didRegisterPhotoLibraryChangeObserver = false
  }

  private func checkPermission() {
    check(permission: .photos, authorized: { [weak self] in
      guard let self else { return }
      registerPhotoLibraryChangeObserver()
      loadDefaultAlbumIfNeeded()
    }, limited: { [weak self] in
      guard let self else { return }
      registerPhotoLibraryChangeObserver()
      loadDefaultAlbumIfNeeded()
//      showLimitedView()
    }, denied: { [weak self] _ in
      guard let self else { return }
//      permissionView.isHidden = false
    })
  }

  private func loadDefaultAlbumIfNeeded() {
    guard album == nil else { return }
    manager.fetchCameraRollAlbum { [weak self] album in
      guard let self else { return }
      setAlbum(album)
      preselectAssets()
      reloadData(animated: false)
      scrollToEnd()
      autoScrollToLatest = true
      preLoadAlbums()
    }
  }

  private func preLoadAlbums() {
    manager.fetchAllAlbums { [weak self] albums in
      guard let self else { return }
      setAlbums(albums)
    }
  }

  private func setAlbum(_ album: Album) {
    guard self.album != album else { return }
    self.album = album
    titleView.setTitle(album.title)
    if manager.options.clearSelectionAfterSwitchingAlbum {
      manager.removeAllSelectedAsset()
    }
    manager.cancelAllFetch()
    album.assets.forEach { asset in
      if
        !manager.options.clearSelectionAfterSwitchingAlbum,
        let selectAsset = manager.selectedAssets.first(where: { asset == $0 })
      {
        asset.state = .selected
        asset.selectedNum = selectAsset.selectedNum
        manager.updateAsset(asset) // The asset selected from other albums, so it should be replaced.
      } else {
        asset.state = .unchecked
      }
    }
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    addCameraAssetIfNeeded()
    #endif
  }

  private func setAlbums(_ albums: [Album]) {
    self.albums = albums.filter { !$0.assets.isEmpty }
    if let albumsPicker {
      albumsPicker.albums = albums
      albumsPicker.reloadData()
    }
  }

  private func reloadAlbums() {
    manager.fetchAllAlbums { [weak self] albums in
      guard let self else { return }
      setAlbums(albums)
      if let identifier = album?.identifier {
        if let idx = (albums.firstIndex { $0.identifier == identifier }) {
          updateAlbum(albums[idx])
        }
      }
    }
  }

  private func reloadAlbum(_ album: Album) {
    guard !stopReloadAlbum else { return }
    manager.fetchAlbum(album) { [weak self] newAlbum in
      guard let self else { return }
      updateAlbum(newAlbum)
      preLoadAlbums()
    }
  }

  private func updateAlbum(_ album: Album) {
    // Update selected assets when album assets changed
    for asset in manager.selectedAssets.reversed() {
      if !(album.assets.contains { $0 == asset }) {
        manager.removeSelectedAsset(asset)
      }
    }
    for asset in manager.selectedAssets {
      if let idx = (album.assets.firstIndex { $0 == asset }) {
        manager.removeSelectedAsset(asset)
        manager.addSelectedAsset(album.assets[idx])
      }
    }
//    toolBar.setEnable(!manager.selectedAssets.isEmpty)

    self.album = album
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    addCameraAssetIfNeeded()
    #endif
    reloadData()
    if manager.options.orderByDate == .asc {
      collectionView.scrollToLast(at: .bottom, animated: true)
    } else {
      collectionView.scrollToFirst(at: .top, animated: true)
    }
  }

  func updateVisibleCellState(_ animatedItem: Int = -1) {
    guard let album else { return }
    for cell in collectionView.visibleCells {
      if let indexPath = collectionView.indexPath(for: cell), let cell = cell as? AssetCell {
        cell.updateState(album.assets[indexPath.item], manager: manager, animated: animatedItem == indexPath.item)
      }
    }
  }

  private func preselectAssets() {
    let preselectAssets = manager.options.preselectAssets
    var selectedAssets: [Asset] = []
    if preselectAssets.isEmpty { return }
    for asset in (album?.assets ?? []).reversed() {
      if preselectAssets.contains(asset.identifier) {
        selectedAssets.append(asset)
        if selectedAssets.count == preselectAssets.count {
          break
        }
      }
    }
    for identifier in preselectAssets {
      if let asset = (selectedAssets.filter { $0.identifier == identifier }).first {
        manager.addSelectedAsset(asset)
      }
    }
  }

  private func scrollToEnd(animated: Bool = false) {
    if manager.options.orderByDate == .asc {
      collectionView.scrollToLast(at: .bottom, animated: animated)
    } else {
      collectionView.scrollToFirst(at: .top, animated: animated)
    }
  }

  func selectItem(_ idx: Int) {
    guard let album else { return }
    let asset = album.assets[idx]

    if !asset.isSelected {
      let result = manager.addSelectedAsset(asset)
      print("Result: \(asset)")
      if !result.success, !result.message.isEmpty {
        showAlert(message: result.message, stringConfig: manager.options.theme)
      }
    } else {
      manager.removeSelectedAsset(asset)
    }
    updateVisibleCellState(idx)

    trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.isSelected, .page: AnyImagePage.pickerAsset])
  }
}

// MARK: - Notification

extension AssetPickerViewController {
  private func addNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(containerSizeDidChange(_:)),
      name: .containerSizeDidChange,
      object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didSyncAsset(_:)), name: .didSyncAsset, object: nil)
  }

  @objc
  private func containerSizeDidChange(_ sender: Notification) {
    containerSize = (sender.userInfo?[containerSizeKey] as? CGSize) ?? ScreenHelper.mainBounds.size
    guard !collectionView.visibleCells.isEmpty else { return }
    let visibleCellRows = collectionView.visibleCells.map { $0.tag }.sorted()
    let row = visibleCellRows[visibleCellRows.count / 2]
    let indexPath = IndexPath(row: row, section: 0)
    reloadData(animated: false)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
  }

  @objc
  private func didSyncAsset(_ sender: Notification) {
    DispatchQueue.main.async {
      guard let _ = sender.object as? String else { return }
      guard self.manager.options.selectLimit == 1, self.manager.options.selectionTapAction.hideToolBar else { return }
      guard let asset = self.manager.selectedAssets.first else { return }
      guard let cell = self.collectionView.cellForItem(at: IndexPath(row: asset.idx, section: 0)) as? AssetCell else { return }
      cell.selectEvent.call()
    }
  }
}

// MARK: - Target

extension AssetPickerViewController {
  // 다른 앨범 구경하기
  @objc
  private func titleViewTapped(_: PickerArrowButton) {
    let controller = AlbumPickerViewController(manager: manager)
    controller.album = album
    controller.albums = albums
    controller.delegate = self
    let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
    let isFullScreen = ScreenHelper.mainBounds.height == (navigationController?.view ?? view).frame.height
    presentationController.isFullScreen = isFullScreen
    controller.transitioningDelegate = presentationController
    albumsPicker = controller
    present(controller, animated: true, completion: nil)
    trackObserver?.track(event: .pickerSwitchAlbum, userInfo: [:])
  }

  @objc
  private func cancelButtonTapped(_: UIBarButtonItem) {
    delegate?.assetPickerDidCancel(self)
    trackObserver?.track(event: .pickerCancel, userInfo: [:])
  }

  @objc
  private func previewButtonTapped(_: UIButton) {
    manager.lastSelectedAssets = manager.selectedAssets
    let controller = PhotoPreviewController(manager: manager, sourceType: .selectedAssets)
    controller.currentIndex = 0
    controller.dataSource = self
    controller.delegate = self
    present(controller, animated: true, completion: nil)
    trackObserver?.track(event: .pickerPreview, userInfo: [:])
  }

  @objc
  private func originalImageButtonTapped(_ sender: UIButton) {
    sender.isSelected.toggle()
    manager.useOriginalImage = sender.isSelected
    trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: sender.isSelected, .page: AnyImagePage.pickerAsset])
  }

  @objc
  func doneButtonTapped(_ sender: UIButton) {
    defer { sender.isEnabled = true }
    sender.isEnabled = false
    stopReloadAlbum = true
    delegate?.assetPickerDidFinishPicking(self)
    trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerAsset])
  }

  @objc
  private func limitedButtonTapped(_: UIButton) {
    if #available(iOS 14.0, *) {
      PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
      trackObserver?.track(event: .pickerLimitedLibrary, userInfo: [:])
    }
  }
}

// MARK: PHPhotoLibraryChangeObserver

extension AssetPickerViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    guard let album, let changeDetails = changeInstance.changeDetails(for: album.fetchResult) else { return }

    if #available(iOS 14.0, *), Permission.photos.status == .limited {
      if album.isCameraRoll {
        reloadAlbum(album)
      } else {
        DispatchQueue.main.async {
          if
            !self.manager.options.clearSelectionAfterSwitchingAlbum,
            let smartAlbum = self.albums.first(where: { $0.isCameraRoll })
          {
            self.setAlbum(smartAlbum)
            self.reloadAlbum(smartAlbum)
            self.updateAlbum(smartAlbum)
          } else {
            self.reloadAlbum(album)
          }
        }
      }
      return
    } else {
      guard changeDetails.hasIncrementalChanges else { return }
    }

    // Check Insert
    let insertedObjects = changeDetails.insertedObjects
    if !insertedObjects.isEmpty {
      reloadAlbum(album)
      return
    }
    // Check Remove
    let removedObjects = changeDetails.removedObjects
    if !removedObjects.isEmpty {
      reloadAlbum(album)
      return
    }
    // Check Change
    let changedObjects = changeDetails.changedObjects
      .filter { changeInstance.changeDetails(for: $0)?.assetContentChanged == true }
    if !changedObjects.isEmpty {
      reloadAlbum(album)
      return
    }
  }
}

// MARK: UICollectionViewDataSource

extension AssetPickerViewController: UICollectionViewDataSource {
  func numberOfSections(in _: UICollectionView) -> Int {
    1
  }

  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    album?.assets.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let asset = album?.assets[indexPath.item] else { return collectionView.dequeueReusableCell(
      UICollectionViewCell.self,
      for: indexPath) }

    let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
    cell.tag = indexPath.row
    cell.setContent(asset, manager: manager)
    cell.selectEvent.delegate(on: self) { (self, _) in
      self.selectItem(indexPath.row)
    }
    cell.backgroundColor = UIColor.clear
    cell.isAccessibilityElement = true
    cell.accessibilityTraits = .button
    let accessibilityLabel = manager.options.theme[string: asset.mediaType == .video ? .video : .photo]
    cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
    return cell
  }
}

// MARK: UICollectionViewDelegate

extension AssetPickerViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset: Asset
    if #available(iOS 14.0, *) {
      guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
      asset = item
    } else {
      guard let album else { return }
      asset = album.assets[indexPath.item]
    }

    #if ANYIMAGEKIT_ENABLE_CAPTURE
    if asset.isCamera { // 点击拍照 Item
      showCapture()
      return
    }
    #endif
    #if ANYIMAGEKIT_ENABLE_EDITOR
    if manager.options.selectionTapAction == .openEditor, canOpenEditor(with: asset) {
      openEditor(with: asset, indexPath: indexPath)
      return
    }
    #endif

    if manager.options.selectionTapAction == .quickPick {
      guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCell else { return }
      cell.selectEvent.call()
      if manager.options.selectLimit == 1, manager.selectedAssets.count == 1 {
        doneButtonTapped(toolBar.doneButton)
      }
    } else if case .disable(let rule) = asset.state {
      let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
      showAlert(message: message, stringConfig: manager.options.theme)
      return
    } else if !asset.isSelected, manager.isUpToLimit {
      return
    } else {
      let controller = PhotoPreviewController(manager: manager, sourceType: .album)
      previewController = controller
      controller.currentIndex = indexPath.item - itemOffset
      controller.dataSource = self
      controller.delegate = self
      present(controller, animated: true, completion: nil)
    }
  }

  func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let asset = album?.assets[indexPath.item], !asset.isCamera else { return }
    if let cell = cell as? AssetCell {
      cell.updateState(asset, manager: manager, animated: false)
    }
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemAt _: IndexPath)
    -> CGSize
  {
    let maxSize = CGRect(origin: .zero, size: containerSize).inset(by: collectionView.contentInset).size
    let columnNumber: CGFloat
    if UIDevice.current.userInterfaceIdiom == .phone || !manager.options.autoCalculateColumnNumber {
      columnNumber = CGFloat(manager.options.columnNumber)
    } else {
      let minWidth: CGFloat = 135
      columnNumber = max(CGFloat(Int(maxSize.width / minWidth)), 3)
    }
    let width = floor((maxSize.width - (columnNumber - 1) * defaultAssetSpacing) / columnNumber)
    // 컬렉션뷰 셀 사이즈 변경 코드
    return CGSize(width: UIScreen.getWidth(115), height: UIScreen.getHeight(204))
  }
}

// MARK: AlbumPickerViewControllerDelegate

extension AssetPickerViewController: AlbumPickerViewControllerDelegate {
  func albumPicker(_: AlbumPickerViewController, didSelected album: Album) {
    setAlbum(album)
    reloadData(animated: false)
    scrollToEnd()
  }

  func albumPickerWillDisappear(_: AlbumPickerViewController) {
    titleView.isSelected = false
    albumsPicker = nil
  }
}

// MARK: PhotoPreviewControllerDataSource

extension AssetPickerViewController: PhotoPreviewControllerDataSource {
  func numberOfPhotos(in controller: PhotoPreviewController) -> Int {
    switch controller.sourceType {
    case .album:
      guard let album else { return 0 }
      #if ANYIMAGEKIT_ENABLE_CAPTURE
      if album.isCameraRoll, !manager.options.captureOptions.mediaOptions.isEmpty {
        return album.assets.count - 1
      }
      #endif
      return album.assets.count
    case .selectedAssets:
      return manager.lastSelectedAssets.count
    }
  }

  func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> PreviewData {
    switch controller.sourceType {
    case .album:
      let idx = index + itemOffset
      let indexPath = IndexPath(item: idx, section: 0)
      let cell = collectionView.cellForItem(at: indexPath) as? AssetCell
      return (cell?.image, album!.assets[idx])
    case .selectedAssets:
      let asset = manager.lastSelectedAssets[index]
      return (asset._image ?? asset._images[.thumbnail], asset)
    }
  }

  func previewController(_ controller: PhotoPreviewController, asset: Asset) -> PreviewData? {
    switch controller.sourceType {
    case .album:
      guard let album, asset.idx < album.assets.count else { return nil }
      if album.assets[asset.idx] == asset {
        return previewController(controller, assetOfIndex: asset.idx)
      } else if let currentAsset = album.assets.first(where: { asset == $0 }) {
        return previewController(controller, assetOfIndex: currentAsset.idx)
      } else {
        return nil
      }
    case .selectedAssets:
      return (asset.image, asset)
    }
  }

  func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView? {
    switch controller.sourceType {
    case .album:
      let idx = index + itemOffset
      let indexPath = IndexPath(item: idx, section: 0)
      return collectionView.cellForItem(at: indexPath)
    case .selectedAssets:
      let asset = manager.lastSelectedAssets[index]
      let idx = asset.idx + itemOffset
      let indexPath = IndexPath(item: idx, section: 0)
      return collectionView.cellForItem(at: indexPath) ?? toolBar.leftButton
    }
  }
}

// MARK: PhotoPreviewControllerDelegate

extension AssetPickerViewController: PhotoPreviewControllerDelegate {
  func previewController(_: PhotoPreviewController, didSelected _: Int) {
    updateVisibleCellState()
    toolBar.setEnable(true)
  }

  func previewController(_: PhotoPreviewController, didDeselected _: Int) {
    updateVisibleCellState()
    toolBar.setEnable(!manager.selectedAssets.isEmpty)
  }

  func previewController(_: PhotoPreviewController, useOriginalImage: Bool) {
    toolBar.originalButton.isSelected = useOriginalImage
  }

  func previewControllerDidClickDone(_: PhotoPreviewController) {
    stopReloadAlbum = true
    delegate?.assetPickerDidFinishPicking(self)
  }

  func previewControllerWillDisappear(_ controller: PhotoPreviewController) {
    switch controller.sourceType {
    case .album:
      let idx = controller.currentIndex + itemOffset
      let indexPath = IndexPath(item: idx, section: 0)
      reloadData(animated: false, reloadPreview: false)
      if !(collectionView.visibleCells.map { $0.tag }).contains(idx) {
        if idx < collectionView.numberOfItems(inSection: 0) {
          collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
      }
    case .selectedAssets:
      break
    }
  }
}

// MARK: - UICollectionViewDiffable

extension AssetPickerViewController {
  enum Section {
    case main
  }

  private func reloadData(animated: Bool = true, reloadPreview: Bool = true) {
    if reloadPreview {
      previewController?.reloadWhenPhotoLibraryDidChange()
    }
    if #available(iOS 14.0, *) {
      let snapshot = initialSnapshot()
      dataSource.apply(snapshot, animatingDifferences: animated)
    } else {
      collectionView.reloadData()
    }
  }

  @available(iOS 14.0, *)
  private func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Asset> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Asset>()
    snapshot.appendSections([.main])
    snapshot.appendItems(album?.assets ?? [], toSection: .main)
    return snapshot
  }

  @available(iOS 14.0, *)
  private func setupDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<AssetCell, Asset> { [weak self] cell, indexPath, asset in
      guard let self else { return }
      cell.tag = indexPath.row
      cell.setContent(asset, manager: manager)
      cell.selectEvent.delegate(on: self) { (self, _) in
        self.selectItem(indexPath.row)
      }
      cell.backgroundColor = UIColor.clear
      cell.isAccessibilityElement = true
      cell.accessibilityTraits = .button
      let accessibilityLabel = manager.options.theme[string: asset.mediaType == .video ? .video : .photo]
      cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
    }

    dataSource = UICollectionViewDiffableDataSource<
      Section,
      Asset
    >(collectionView: collectionView) { collectionView, indexPath, asset -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: asset)
    }
  }
}
