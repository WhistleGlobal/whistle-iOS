//
//  VideoEditorCropProgressView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - VideoEditorCropProgressViewDelegate

protocol VideoEditorCropProgressViewDelegate: AnyObject {
  func cropProgress(_ view: VideoEditorCropProgressView, didUpdate progress: CGFloat)
  func cropProgressDurationOfVideo(_ view: VideoEditorCropProgressView) -> CGFloat
}

// MARK: - VideoEditorCropProgressView

final class VideoEditorCropProgressView: UIView {
  public weak var delegate: VideoEditorCropProgressViewDelegate?
  private let options: EditorVideoOptionsInfo

  private(set) var leftProgress: CGFloat = 0
  private(set) var rightProgress: CGFloat = 1
  private var clipRange: ClosedRange<CGFloat> = 0 ... 1
  private let minClipLength: CGFloat = 0.2

  public var progress: CGFloat {
    let x = contentView.frame.origin.x + progressView.frame.origin.x
    return x / (bounds.width - 20)
  }

  private var videoDuration: CGFloat = 0

  private lazy var contentView: UIView = {
    let view = UIView(frame: .zero)
    view.layer.cornerRadius = 5
    return view
  }()

  private lazy var progressContentView: UIView = {
    let view = UIView(frame: .zero)
    let pan = UIPanGestureRecognizer(target: self, action: #selector(progressViewPan(_:)))
    view.addGestureRecognizer(pan)
    return view
  }()

  private lazy var progressView: UIView = {
    let view = UIView(frame: .zero)
    view.layer.cornerRadius = 2.5
    view.backgroundColor = UIColor.white
    return view
  }()

  private lazy var leftButton: UIButton = {
    let view = UIButton(type: .custom)
    view.setImage(options.theme[icon: .videoCropLeft], for: .normal)
    let pan = UIPanGestureRecognizer(target: self, action: #selector(leftButtonPan(_:)))
    view.addGestureRecognizer(pan)
    return view
  }()

  private lazy var rightButton: UIButton = {
    let view = UIButton(type: .custom)
    view.setImage(options.theme[icon: .videoCropRight], for: .normal)
    let pan = UIPanGestureRecognizer(target: self, action: #selector(rightButtonPan(_:)))
    view.addGestureRecognizer(pan)
    return view
  }()

  private lazy var contentLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.isHidden = true
    layer.frame = bounds
    layer.fillRule = .evenOdd
    layer.fillColor = options.theme[color: .primary].cgColor
    return layer
  }()

  private lazy var darkLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.frame = bounds
    layer.fillRule = .evenOdd
    layer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
    return layer
  }()

  private lazy var timeline: UIView = {
    let view = UIView(frame: .zero)
    view.isHidden = true
    view.backgroundColor = UIColor.white
    return view
  }()

  private lazy var timelineLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.isHidden = true
    view.textColor = UIColor.white
    view.font = UIFont.systemFont(ofSize: 12)
    return view
  }()

  /// 预览图
  private var previews: [UIImageView] = []

  init(frame: CGRect, options: EditorVideoOptionsInfo) {
    self.options = options
    super.init(frame: frame)
    layer.cornerRadius = 5
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layout(updateProgress: false)
  }

  private func setupView() {
    layer.addSublayer(darkLayer)
    contentView.layer.addSublayer(contentLayer)

    addSubview(contentView)
    addSubview(progressContentView)
    contentView.addSubview(leftButton)
    contentView.addSubview(rightButton)
    progressContentView.addSubview(progressView)
    progressContentView.addSubview(timeline)
    progressContentView.addSubview(timelineLabel)

    contentView.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.left.equalToSuperview()
      maker.right.equalToSuperview()
    }
    leftButton.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.left.equalToSuperview()
      maker.width.equalTo(20)
    }
    rightButton.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.right.equalToSuperview()
      maker.width.equalTo(20)
    }
    progressContentView.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.left.equalTo(leftButton.snp.right)
      maker.right.equalTo(rightButton.snp.left)
    }
    progressView.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview().inset(3)
      maker.width.equalTo(5)
      maker.left.equalToSuperview()
    }
    timeline.snp.makeConstraints { maker in
      maker.bottom.equalTo(progressView.snp.top).offset(-8)
      maker.centerX.equalTo(progressView)
      maker.width.equalTo(1)
      maker.height.equalTo(15)
    }
    timelineLabel.snp.makeConstraints { maker in
      maker.bottom.equalTo(timeline.snp.top).offset(-8)
      maker.centerX.equalTo(timeline)
    }

    options.theme.labelConfiguration[.videoTimeline]?.configuration(timelineLabel)
    options.theme.buttonConfiguration[.videoCropLeft]?.configuration(leftButton)
    options.theme.buttonConfiguration[.videoCropRight]?.configuration(rightButton)
  }

  private func layout(updateProgress: Bool) {
    let isSelected = rightProgress - leftProgress != 1
    leftButton.isSelected = isSelected
    rightButton.isSelected = isSelected
    contentLayer.isHidden = !isSelected

    contentView.snp.updateConstraints { maker in
      maker.left.equalToSuperview().offset(leftProgress * bounds.width)
      maker.right.equalToSuperview().offset(-((1 - rightProgress) * (bounds.width)))
    }
    if updateProgress {
      progressView.snp.updateConstraints { maker in
        maker.left.equalToSuperview()
      }
    }
    contentLayer.frame = contentView.bounds
    updateContentLayer()
    updateDarkLayer()
  }

  private func updateContentLayer() {
    let contentPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 5)
    var rect = contentView.bounds
    rect.origin.x += 20
    rect.origin.y += 5
    rect.size.width -= 40
    rect.size.height -= 10
    let rectPath = UIBezierPath(rect: rect)
    contentPath.append(rectPath)
    contentLayer.path = contentPath.cgPath
  }

  private func updateDarkLayer() {
    let darkPath = UIBezierPath(rect: bounds)
    let rectPath = UIBezierPath(rect: contentView.frame)
    darkPath.append(rectPath)
    darkLayer.path = darkPath.cgPath
  }
}

// MARK: - Public

extension VideoEditorCropProgressView {
  public func setupProgressImages(_ count: Int, image: UIImage?) {
    previews = (0 ..< count).map { _ in UIImageView(image: image) }
    let stackView = UIStackView(arrangedSubviews: previews)
    stackView.spacing = 0
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    insertSubview(stackView, at: 0)
    stackView.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview().inset(5)
      maker.left.right.equalToSuperview().inset(20)
    }
  }

  public func setProgressImage(_ image: UIImage, idx: Int) {
    guard idx < previews.count else { return }
    previews[idx].setImage(image, animated: true)
  }

  public func setProgress(_ progress: CGFloat) {
    var progress = progress < 0 ? 0 : (progress > 1 ? 1 : progress)
    progress = progress < leftProgress ? leftProgress : (progress > rightProgress ? rightProgress : progress)
    let offset = (progress - leftProgress) / (rightProgress - leftProgress) *
      (progressContentView.frame.width - progressView.frame.width)
    progressView.snp.updateConstraints { maker in
      maker.left.equalToSuperview().offset(offset)
    }

    // Label
    if videoDuration == 0 || videoDuration.isNaN {
      videoDuration = delegate?.cropProgressDurationOfVideo(self) ?? 0.0
    }
    if videoDuration != 0, !timeline.isHidden, !videoDuration.isNaN {
      let time = Int(videoDuration * progress)
      let min = time / 60
      let sec = time % 60
      timelineLabel.text = String(format: "%02ld:%02ld", min, sec)
    }
  }

  func setCropProgress(_ range: ClosedRange<CGFloat>) {
    clipRange = range
    leftProgress = range.lowerBound
    rightProgress = range.upperBound
    setProgress(leftProgress)
    layout(updateProgress: true)
    delegate?.cropProgress(self, didUpdate: leftProgress)
  }
}

// MARK: - Target

extension VideoEditorCropProgressView {
  @objc
  private func progressViewPan(_ pan: UIPanGestureRecognizer) {
    let point = pan.location(in: self)
    let progress = point.x / bounds.width
    setProgress(progress)
    if progress < leftProgress || progress > rightProgress {
      return
    }
    delegate?.cropProgress(self, didUpdate: progress)
    setTimeline(hidden: pan.state != .changed)
  }

  @objc
  private func leftButtonPan(_ pan: UIPanGestureRecognizer) {
    let point = pan.location(in: self)
    let x = point.x < 0 ? 0 : point.x
    let tmpLeft = x / bounds.width

    let clipLength = clipRange.upperBound - clipRange.lowerBound
    if clipLength == 1 {
      if rightProgress - tmpLeft < minClipLength {
        setLeftButton(tmpLeft, clipLength: minClipLength)
        setRightButton(tmpLeft + minClipLength, clipLength: minClipLength)
      } else {
        setLeftButton(tmpLeft, clipLength: minClipLength)
      }
    } else {
      setLeftButton(tmpLeft, clipLength: clipLength)
      setRightButton(tmpLeft + clipLength, clipLength: clipLength)
    }

    setProgress(leftProgress)
    layout(updateProgress: false)
    delegate?.cropProgress(self, didUpdate: leftProgress)
    setTimeline(hidden: pan.state != .changed)
  }

  @objc
  private func rightButtonPan(_ pan: UIPanGestureRecognizer) {
    let point = pan.location(in: self)
    let x = point.x > bounds.width ? bounds.width : point.x
    let tmpRight = x / bounds.width

    let clipLength = clipRange.upperBound - clipRange.lowerBound
    if clipLength == 1 {
      if tmpRight - leftProgress < minClipLength {
        setLeftButton(tmpRight - minClipLength, clipLength: minClipLength)
        setRightButton(tmpRight, clipLength: minClipLength)
      } else {
        setRightButton(tmpRight, clipLength: minClipLength)
      }
    } else {
      setLeftButton(tmpRight - clipLength, clipLength: clipLength)
      setRightButton(tmpRight, clipLength: clipLength)
    }

    setProgress(rightProgress)
    layout(updateProgress: false)
    delegate?.cropProgress(self, didUpdate: rightProgress)
    setTimeline(hidden: pan.state != .changed)
    if pan.state == .ended || pan.state == .cancelled {
      setProgress(leftProgress)
      delegate?.cropProgress(self, didUpdate: leftProgress)
    }
  }

  private func setLeftButton(_ offset: CGFloat, clipLength: CGFloat) {
    leftProgress = max(0, min(offset, 1 - clipLength))
  }

  private func setRightButton(_ offset: CGFloat, clipLength: CGFloat) {
    rightProgress = min(1, max(offset, clipLength))
  }
}

// MARK: - Private

extension VideoEditorCropProgressView {
  private func setTimeline(hidden: Bool) {
    timeline.isHidden = hidden
    timelineLabel.isHidden = hidden
  }
}