//
//  ImagePickerController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import SnapKit
import UIKit
import SwiftUI
import VideoPicker

// MARK: - ImagePickerControllerDelegate

public protocol ImagePickerControllerDelegate: AnyObject {
  func imagePickerDidCancel(_ picker: ImagePickerController)
  func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult)
}

extension ImagePickerControllerDelegate {
  public func imagePickerDidCancel(_ picker: ImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

// MARK: - ImagePickerController

open class ImagePickerController: AnyImageNavigationController {
  open weak var pickerDelegate: ImagePickerControllerDelegate?

  private var containerSize: CGSize = .zero
  private var didFinishSelect = false
  private var didCallback = false
  private let workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.ImagePickerController")

  private let manager: PickerManager = .init()

  public required init() {
    super.init(nibName: nil, bundle: nil)
  }

  /// Init Picker
  public convenience init(options: PickerOptionsInfo, delegate: ImagePickerControllerDelegate) {
    self.init()
    update(options: options)
    pickerDelegate = delegate
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  deinit {
    removeNotifications()
    #if ANYIMAGEKIT_ENABLE_EDITOR
    ImageEditorCache.clearDiskCache()
    #endif
    manager.clearAll()
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    addNotifications()

    let topBorderLayer = CALayer()
    topBorderLayer.backgroundColor = UIColor(named: "Gray20_Dark")?.withAlphaComponent(0.36).cgColor
    topBorderLayer.frame = CGRect(
      x: 0,
      y: navigationController?.navigationBar.frame.height ?? 56.0,
      width: view.frame.size.width,
      height: 1)
    view.layer.addSublayer(topBorderLayer)
    let gradient = UIImage.gradientImage(
      bounds: view.bounds,
      colors: [UIColor.white.withAlphaComponent(0.16), .white.withAlphaComponent(0.48)])
    let gradientColor = UIColor(patternImage: gradient)

    view.layer.borderColor = gradientColor.cgColor
    view.layer.borderWidth = 1.0
    view.layer.cornerRadius = 20

    #if ANYIMAGEKIT_ENABLE_EDITOR
    ImageEditorCache.clearDiskCache()
    #endif
  }

  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let newSize = view.frame.size
    if containerSize != .zero, containerSize != newSize {
      _print("ImagePickerController container size did change, new size = \(newSize)")
      NotificationCenter.default.post(name: .containerSizeDidChange, object: nil, userInfo: [containerSizeKey: newSize])
    }
    containerSize = newSize
  }

  override open func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    if let previewController = presentedViewController as? PhotoPreviewController {
      previewController.transitioningDelegate = nil
      presentingViewController?.dismiss(animated: flag, completion: completion)
    } else {
      super.dismiss(animated: flag, completion: completion)
    }
  }

  override open var shouldAutorotate: Bool {
    #if ANYIMAGEKIT_ENABLE_EDITOR
    if manager.options.editorOptions.isEmpty {
      return true
    } else {
      return false
    }
    #else
    return true
    #endif
  }

  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    #if ANYIMAGEKIT_ENABLE_EDITOR
    if manager.options.editorOptions.isEmpty {
      return .all
    } else {
      switch UIApplication.shared.statusBarOrientation {
      case .unknown:
        return .portrait
      case .portrait:
        return .portrait
      case .portraitUpsideDown:
        return .portraitUpsideDown
      case .landscapeLeft:
        return .landscapeLeft
      case .landscapeRight:
        return .landscapeRight
      }
    }
    #else
    return .all
    #endif
  }

  override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    UIApplication.shared.statusBarOrientation
  }
}

extension ImagePickerController {
  public func update(options: PickerOptionsInfo) {
    guard viewControllers.isEmpty || enableForceUpdate else {
      return
    }
    enableDebugLog = options.enableDebugLog
    manager.clearAll()
    manager.options = check(options: options)

    let rootViewController = AssetPickerViewController(manager: manager)
    rootViewController.delegate = self
    rootViewController.trackObserver = self
    viewControllers = [rootViewController]

    navigationBar.barTintColor = manager.options.theme[color: .background]
    navigationBar.tintColor = manager.options.theme[color: .whiteText]
  }
}

// MARK: - Private function

extension ImagePickerController {
  /// PickerOptionsInfo를 확인하고 올바른 값으로 보정하는 내부 메서드입니다. 예를 들어, 최소 선택 제한, 열의 수 등을 확인하고 보정합니다.
  private func check(options: PickerOptionsInfo) -> PickerOptionsInfo {
    var options = options
    options.largePhotoMaxWidth = max(options.photoMaxWidth, options.largePhotoMaxWidth)

    #if DEBUG
    assert(options.selectLimit >= 1, "Select limit should more then 1")
    #else
    if options.selectLimit < 1 {
      options.selectLimit = 1
    }
    #endif

    if options.columnNumber < 3 {
      options.columnNumber = 3
    } else if options.columnNumber > 5 {
      options.columnNumber = 5
    }

    if options.selectLimit < options.preselectAssets.count {
      options.preselectAssets.removeLast(options.preselectAssets.count - options.selectLimit)
    }

    return options
  }

  private func checkData() {
    view.hud.show()
    workQueue.async { [weak self] in
      guard let self else { return }
      let assets = manager.selectedAssets
      let isReady = assets.filter { !$0.isReady }.isEmpty
      if !isReady, !assets.isEmpty { return }
      saveEditPhotos(assets) { newAssets in
        self.resizeImagesIfNeeded(newAssets)
        DispatchQueue.main.async {
          self.view.hud.hide()
          let result = PickerResult(assets: newAssets, useOriginalImage: self.manager.useOriginalImage)
          guard self.didCallback == false else { return }
          self.pickerDelegate?.imagePicker(self, didFinishPicking: result)
          let pickerResultView = TestPickerResultView(result: result)
          let hostingController = UIHostingController(rootView: pickerResultView)
      }
    }
  }

  private func saveEditPhotos(_ assets: [Asset], completion: @escaping (([Asset]) -> Void)) {
    #if ANYIMAGEKIT_ENABLE_EDITOR
    guard manager.options.saveEditedAsset else {
      completion(assets)
      return
    }
    var assets = assets
    let selectOptions = manager.options.selectOptions
    let group = DispatchGroup()
    for (idx, asset) in assets.enumerated() {
      guard let editedImage = asset._images[.edited] else { continue }
      group.enter()
      manager.savePhoto(image: editedImage) { result in
        switch result {
        case .success(let newAsset):
          assets[idx] = Asset(idx: asset.idx, asset: newAsset, selectOptions: selectOptions)
          assets[idx]._images[.initial] = editedImage
        case .failure(let error):
          _print(error)
        }
        group.leave()
      }
    }
    group.notify(queue: workQueue) {
      completion(assets)
    }
    #else
    completion(assets)
    #endif
  }

  private func resizeImagesIfNeeded(_ assets: [Asset]) {
    if !manager.useOriginalImage {
      let limitSize = CGSize(
        width: manager.options.photoMaxWidth,
        height: manager.options.photoMaxWidth)
      assets.forEach {
        if let image = $0._image, image.size != .zero {
          let resizedImage = UIImage.resize(from: image, limitSize: limitSize, isExact: true)
          $0._images[.output] = resizedImage
          $0._images[.edited] = nil
          $0._images[.initial] = nil
        }
      }
    } else {
      assets.forEach {
        $0._images[.output] = $0._image
        $0._images[.edited] = nil
        $0._images[.initial] = nil
      }
    }
  }
}

// MARK: AssetPickerViewControllerDelegate

extension ImagePickerController: AssetPickerViewControllerDelegate {
  func assetPickerDidCancel(_: AssetPickerViewController) {
    pickerDelegate?.imagePickerDidCancel(self)
  }

  func assetPickerDidFinishPicking(_: AssetPickerViewController) {
    didFinishSelect = true
    manager.resynchronizeAsset()
    checkData()
  }
}

// MARK: - Notifications

extension ImagePickerController {
  private func addNotifications() {
    beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(didSyncAsset(_:)), name: .didSyncAsset, object: nil)
  }

  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
    endGeneratingDeviceOrientationNotifications()
  }

  @objc
  private func didSyncAsset(_ sender: Notification) {
    DispatchQueue.main.async {
      if self.didFinishSelect {
        if let message = sender.object as? String {
          self.didFinishSelect = false
          self.view.hud.hide()
          Toast.show(message: message)
        } else {
          self.checkData()
        }
      }
    }
  }
}
