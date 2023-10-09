//
//  AssetCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Kingfisher
import UIKit

// MARK: - AssetCell

final class AssetCell: UICollectionViewCell {
  let selectEvent: Delegate<Void, Void> = .init()

  private lazy var imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .scaleAspectFill
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()

  private lazy var videoView: VideoView = {
    let view = VideoView()
    view.isHidden = true
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()

  private lazy var editedView: EditedView = {
    let view = EditedView()
    view.isHidden = true
    return view
  }()

  private var identifier = ""

  override func prepareForReuse() {
    super.prepareForReuse()
    identifier = ""
    videoView.isHidden = true
    editedView.isHidden = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    contentView.addSubview(imageView)
    contentView.addSubview(videoView)
    contentView.addSubview(editedView)

    imageView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    videoView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    editedView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}

// MARK: PickerOptionsConfigurable

extension AssetCell: PickerOptionsConfigurable {
  func update(options: PickerOptionsInfo) {
    updateChildrenConfigurable(options: options)
  }
}

extension AssetCell {
  var image: UIImage? {
    imageView.image
  }
}

// MARK: - Action

extension AssetCell {
  func setContent(_ asset: Asset, manager: PickerManager, animated: Bool = false, isPreview: Bool = false) {
    let options = _PhotoFetchOptions(sizeMode: .thumbnail(100 * UIScreen.main.nativeScale), needCache: false)
    identifier = asset.identifier
    manager.requestPhoto(for: asset.phAsset, options: options, completion: { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        guard identifier == asset.identifier else { return }
        asset._images[.thumbnail] = response.image
        imageView.image = asset._image ?? response.image
        if asset.mediaType == .video, !isPreview {
          videoView.setVideoTime(asset.durationDescription)
        }
      case .failure(let error):
        _print(error)
      }
    })

    updateState(asset, manager: manager, animated: animated, isPreview: isPreview)
  }

  func updateState(_ asset: Asset, manager: PickerManager, animated _: Bool = false, isPreview _: Bool = false) {
    asset.check(disable: manager.options.disableRules, assetList: manager.selectedAssets)
    update(options: manager.options)
    if asset._images[.edited] != nil {
      editedView.isHidden = false
    } else {
      switch asset.mediaType {
      case .video:
        videoView.isHidden = false
      default:
        break
      }
    }
  }
}

// MARK: - VideoView

private class VideoView: UIView {
  private lazy var videoImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    return view
  }()

  private lazy var videoLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.isHidden = true
    view.textColor = UIColor.white
    view.font = UIFont.systemFont(ofSize: 12)
    return view
  }()

  private lazy var coverLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.frame = CGRect(x: 0, y: self.bounds.height - 35, width: self.bounds.width, height: 35)
    layer.colors = [
      UIColor.black.withAlphaComponent(0.5).cgColor,
      UIColor.black.withAlphaComponent(0).cgColor,
    ]
    layer.locations = [0, 1]
    layer.startPoint = CGPoint(x: 0.5, y: 1)
    layer.endPoint = CGPoint(x: 0.5, y: 0)
    return layer
  }()

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 12
    layer.masksToBounds = true
    coverLayer.frame = CGRect(x: 0, y: bounds.height - 35, width: bounds.width, height: 35)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    layer.addSublayer(coverLayer)
    addSubview(videoImageView)
    addSubview(videoLabel)

    videoImageView.snp.makeConstraints { maker in
      maker.left.bottom.equalToSuperview().inset(8)
      maker.width.equalTo(24)
      maker.height.equalTo(15)
    }
    videoLabel.snp.makeConstraints { maker in
      maker.right.equalTo(0).offset(-8)
      maker.centerY.equalTo(videoImageView)
    }
  }
}

extension VideoView {
  func setVideoTime(_ time: String) {
    videoLabel.isHidden = false
    videoLabel.text = time
  }
}

// MARK: PickerOptionsConfigurable

extension VideoView: PickerOptionsConfigurable {
  func update(options: PickerOptionsInfo) {
    updateChildrenConfigurable(options: options)
    options.theme.labelConfiguration[.assetCellVideoDuration]?.configuration(videoLabel)
  }
}

// MARK: - EditedView

private class EditedView: UIView {
  private lazy var imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    return view
  }()

  private lazy var coverLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.frame = CGRect(x: 0, y: self.bounds.height - 35, width: self.bounds.width, height: 35)
    layer.colors = [
      UIColor.black.withAlphaComponent(0.5).cgColor,
      UIColor.black.withAlphaComponent(0).cgColor,
    ]
    layer.locations = [0, 1]
    layer.startPoint = CGPoint(x: 0.5, y: 1)
    layer.endPoint = CGPoint(x: 0.5, y: 0)
    return layer
  }()

  override func layoutSubviews() {
    super.layoutSubviews()
    coverLayer.frame = CGRect(x: 0, y: bounds.height - 35, width: bounds.width, height: 35)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    layer.addSublayer(coverLayer)
    addSubview(imageView)

    imageView.snp.makeConstraints { maker in
      maker.left.bottom.equalToSuperview().inset(6)
    }
  }
}

// MARK: PickerOptionsConfigurable

extension EditedView: PickerOptionsConfigurable {
  func update(options: PickerOptionsInfo) {
    updateChildrenConfigurable(options: options)
  }
}
