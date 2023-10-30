//
//  VideoPreviewCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import MediaPlayer
import UIKit

// MARK: - VideoPreviewCell

final class VideoPreviewCell: PreviewCell {
  /// 取图片适屏size
  override var fitSize: CGSize {
    guard let image = imageView.image else { return CGSize.zero }
    let width = scrollView.bounds.width
    var size: CGSize = .zero
    if image.size.height > image.size.width {
      let scale = image.size.height / image.size.width
      size = CGSize(width: width, height: scale * width)
      let screenSize = ScreenHelper.mainBounds.size
      if size.width > size.height {
        size.width = size.width * screenSize.height / size.height
        size.height = screenSize.height
      }
    } else {
      let scale = image.size.height / image.size.width
      size = CGSize(width: width, height: width * scale)
    }
    return size
  }

  var isPlaying: Bool {
    if let player {
      return player.rate != 0
    }
    return false
  }

  private var player: AVPlayer?
  private var playerLayer: AVPlayerLayer?

  private lazy var playImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    addSubview(playImageView)
    playImageView.snp.makeConstraints { maker in
      maker.width.height.equalTo(80)
      maker.center.equalToSuperview()
    }
  }

  override func layout() {
    super.layout()
    playerLayer?.frame = imageView.bounds
  }

  /// 重置
  override func reset() {
    setPlayButton(hidden: false)

    imageView.image = nil
    player = nil
    playerLayer = nil

    for layer in imageView.layer.sublayers ?? [] {
      layer.removeFromSuperlayer()
    }
  }

  /// 单击事件触发时，处理播放和暂停的逻辑
  override func singleTapped() {
    let toolBarIsHidden = delegate?.previewCellGetToolBarHiddenState() ?? true
    if player == nil {
      super.singleTapped()
    } else {
      if !toolBarIsHidden, isPlaying { // 工具栏展示 && 在播放视频 -> 暂停视频
        player?.pause()
      } else if toolBarIsHidden, !isPlaying { // 工具栏隐藏 && 未播放视频 -> 播放视频
        player?.play()
      } else {
        super.singleTapped()
        if isPlaying {
          player?.pause()
        } else {
          player?.play()
        }
      }
    }

    setPlayButton(hidden: isPlaying)
  }

  override func panScale(_ scale: CGFloat) {
    super.panScale(scale)
    UIView.animate(withDuration: 0.25) {
      self.setPlayButton(hidden: true, animated: true)
    }
  }

  override func panEnded(_ exit: Bool) {
    super.panEnded(exit)
    if !exit, !isPlaying {
      setPlayButton(hidden: false, animated: true)
    }
  }

  override func optionsDidUpdate(options: PickerOptionsInfo) {
    playImageView.image = options.theme[icon: .videoPlay]
    accessibilityLabel = options.theme[string: .video]
  }
}

// MARK: - Function

extension VideoPreviewCell {
  /// 暂停
  func pause() {
    player?.pause()
    setPlayButton(hidden: false)
  }

  /// 加载图片
  func requestPhoto() {
    let id = asset.identifier
    if imageView.image == nil { // thumbnail
      let options = _PhotoFetchOptions(sizeMode: .thumbnail(100 * UIScreen.main.nativeScale), needCache: false)
      manager.requestPhoto(for: asset.phAsset, options: options, completion: { [weak self] result in
        guard let self else { return }
        switch result {
        case .success(let response):
          if imageView.image == nil, asset.identifier == id {
            setImage(response.image)
          }
        case .failure(let error):
          WhistleLogger.logger.debug("Error: \(error)")
        }
      })
    }

    let options = _PhotoFetchOptions(sizeMode: .preview(500), needCache: true)
    manager.requestPhoto(for: asset.phAsset, options: options) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        guard !response.isDegraded, asset.identifier == id else { return }
        imageView.image = response.image
        imageView.frame = fitFrame
      case .failure(let error):
        WhistleLogger.logger.debug("Error: \(error)")
      }
    }
  }

  // 加载视频
  func requestVideo() {
    let id = asset.identifier
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      let options = VideoFetchOptions(isNetworkAccessAllowed: true) { progress, _, _, _ in
        DispatchQueue.main.async { [weak self] in
          guard let self, asset.identifier == id else { return }
          _print("Download video from iCloud: \(progress)")
          setDownloadingProgress(progress)
        }
      }
      manager.requestVideo(for: asset.phAsset, options: options) { result in
        switch result {
        case .success(let response):
          DispatchQueue.main.async { [weak self] in
            guard let self, asset.identifier == id else { return }
            setPlayerItem(response.playerItem)
            setDownloadingProgress(1.0)
          }
        case .failure(let error):
          _print(error)
        }
      }
    }
  }
}

// MARK: - Private function

extension VideoPreviewCell {
  /// 设置 PlayerItem
  private func setPlayerItem(_ item: AVPlayerItem) {
    player = AVPlayer(playerItem: item)
    playerLayer = AVPlayerLayer(player: player)
    imageView.layer.addSublayer(playerLayer!)
    playerLayer?.frame = imageView.bounds
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerDidPlayToEndTime(_:)),
      name: .AVPlayerItemDidPlayToEndTime,
      object: item)
  }

  /// 设置播放按钮的展示状态
  private func setPlayButton(hidden: Bool, animated: Bool = false) {
    UIView.animate(withDuration: animated ? 0.25 : 0) {
      self.playImageView.alpha = hidden ? 0 : 1
    }
  }
}

// MARK: - Target

extension VideoPreviewCell {
  @objc
  private func playerDidPlayToEndTime(_: Notification) {
    super.singleTapped()
    setPlayButton(hidden: false)
    player?.pause()
    player?.seek(to: .zero)
  }
}
