//
//  PhotoEditorContentView+Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - Internal function

extension PhotoEditorContentView {
  /// 在子线程创建马赛克图片
  func setupMosaicView(completion: @escaping ((Bool) -> Void)) {
    guard mosaic == nil else { completion(false); return }
    DispatchQueue.global().async { [weak self] in
      guard let self else { completion(false); return }
      guard let mosaicImage = createMosaicImage() else { completion(false); return }
      DispatchQueue.main.async { [weak self] in
        guard let self else { completion(false); return }
        _print("Mosaic created")
        mosaic = Mosaic(
          mosaicOptions: options.mosaicOptions,
          originalMosaicImage: mosaicImage)
        mosaic?.delegate = self
        mosaic?.dataSource = self
        mosaic?.isUserInteractionEnabled = false
        imageView.insertSubview(mosaic!, belowSubview: canvas)
        updateSubviewFrame()
        completion(true)
        cacheMosaicImageIfNeeded(mosaicImage)
      }
    }
  }

  private func cacheMosaicImageIfNeeded(_ image: UIImage) {
    guard
      !options.cacheIdentifier.isEmpty,
      let data = image.jpegData(compressionQuality: 1.0)
    else { return }
    let filename = options.cacheIdentifier
    let queue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.CacheMosaicImage")
    queue.async {
      FileHelper.write(photoData: data, fileType: .jpeg, filename: filename)
    }
  }

  private func createMosaicImage() -> UIImage? {
    if !options.cacheIdentifier.isEmpty {
      if let data = FileHelper.read(fileType: .jpeg, filename: options.cacheIdentifier) {
        return UIImage(data: data)
      }
    }
    return image.mosaicImage(level: options.mosaicLevel)
  }
}

// MARK: - PhotoEditorContentView + MosaicDelegate

extension PhotoEditorContentView: MosaicDelegate {
  func mosaicDidBeginDraw() {
    context.action(.mosaicBeginDraw)
  }

  func mosaicDidEndDraw() {
    guard let mosaic else { return }
    context.action(.mosaicFinishDraw(mosaic.contentViews.map { MosaicData(idx: $0.idx, drawnPaths: $0.drawnPaths) }))
  }
}

// MARK: - PhotoEditorContentView + MosaicDataSource

extension PhotoEditorContentView: MosaicDataSource {
  func mosaicGetLineWidth() -> CGFloat {
    let scale = scrollView.zoomScale
    return options.mosaicWidth / scale
  }
}
