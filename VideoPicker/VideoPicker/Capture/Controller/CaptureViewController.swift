//
//  CaptureViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - CaptureViewControllerDelegate

protocol CaptureViewControllerDelegate: AnyObject {
  func captureDidCancel(_ capture: CaptureViewController)
  func capture(_ capture: CaptureViewController, didOutput mediaURL: URL, type: MediaType)
}

// MARK: - CaptureViewController

final class CaptureViewController: AnyImageViewController {
  weak var delegate: CaptureViewControllerDelegate?

  private lazy var previewView: CapturePreviewView = {
    let view = CapturePreviewView(frame: .zero, options: options)
    view.delegate = self
    return view
  }()

  private lazy var toolView: CaptureToolView = {
    let view = CaptureToolView(frame: .zero, options: options)
    view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
    view.switchButton.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .touchUpInside)
    view.switchButton.isHidden = options.preferredPositions.count <= 1
    if let stringKey = options.preferredPositions.first?.localizedTipsKey {
      view.switchButton.accessibilityLabel = options.theme[string: stringKey]
    }
    view.captureButton.delegate = self
    return view
  }()

  private lazy var tipsView: CaptureTipsView = {
    let view = CaptureTipsView(frame: .zero, options: options)
    view.isHidden = true
    view.isAccessibilityElement = false
    return view
  }()

  private lazy var capture: Capture = {
    let capture = Capture(options: options)
    capture.delegate = self
    return capture
  }()

  private lazy var recorder: Recorder = {
    let recorder = Recorder()
    recorder.delegate = self
    return recorder
  }()

  private lazy var orientationUtil: DeviceOrientationUtil = {
    let util = DeviceOrientationUtil()
    util.delegate = self
    return util
  }()

  private var permissionsChecked = false
  private let options: CaptureOptionsInfo

  init(options: CaptureOptionsInfo) {
    self.options = options
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    setupView()
    var permissions: [Permission] = [.camera]
    if options.mediaOptions.contains(.video) {
      permissions.append(.microphone)
    }
    check(permissions: permissions, stringConfig: options.theme, authorized: { [weak self] in
      guard let self else { return }
      permissionsChecked = true
      capture.startRunning()
      orientationUtil.startRunning()
    }, canceled: { [weak self] _ in
      guard let self else { return }
      delegate?.captureDidCancel(self)
    })
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tipsView.showTips(hideAfter: 3, animated: true)
    if permissionsChecked {
      capture.focus()
      capture.exposure()
      previewView.autoFocus(isForce: true)
    }
  }

  private func setupNavigation() {
    navigationController?.navigationBar.isHidden = true
  }

  private func setupView() {
    view.backgroundColor = .black
    let layoutGuide = UILayoutGuide()
    view.addLayoutGuide(layoutGuide)
    view.addSubview(previewView)
    view.addSubview(toolView)
    view.addSubview(tipsView)
    previewView.snp.makeConstraints { maker in
      maker.left.right.equalToSuperview()
      maker.center.equalToSuperview()
      maker.width.equalTo(previewView.snp.height).multipliedBy(9.0 / 16.0)
    }
    layoutGuide.snp.makeConstraints { maker in
      maker.left.right.equalToSuperview()
      maker.center.equalToSuperview()
      maker.width.equalTo(layoutGuide.snp.height).multipliedBy(9.0 / 16.0)
    }
    toolView.snp.makeConstraints { maker in
      maker.left.right.equalToSuperview()
      maker.bottom.equalTo(layoutGuide.snp.bottom)
      maker.height.equalTo(88)
    }
    tipsView.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.bottom.equalTo(toolView.snp.top).offset(-8)
    }
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}

// MARK: - Target

extension CaptureViewController {
  @objc
  private func cancelButtonTapped(_: UIButton) {
    delegate?.captureDidCancel(self)
    trackObserver?.track(event: .captureCancel, userInfo: [:])
  }

  @objc
  private func switchButtonTapped(_ sender: UIButton) {
    impactFeedback()
    toolView.hideButtons(animated: true)
    previewView.transitionFlip(isIn: sender.isSelected, stopPreview: { [weak self] in
      guard let self else { return }
      capture.startSwitchCamera()
    }, startPreview: { [weak self] in
      guard let self else { return }
      let newPosition = capture.stopSwitchCamera()
      sender.accessibilityLabel = options.theme[string: newPosition.localizedTipsKey]
    }) { [weak self] in
      guard let self else { return }
      toolView.showButtons(animated: true)
    }
    sender.isSelected.toggle()
    trackObserver?.track(event: .captureSwitchCamera, userInfo: [:])
  }
}

// MARK: - Impact Feedback

extension CaptureViewController {
  private func impactFeedback() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.prepare()
    impactFeedback.impactOccurred()
  }
}

// MARK: CaptureButtonDelegate

extension CaptureViewController: CaptureButtonDelegate {
  func captureButtonDidTapped(_ button: CaptureButton) {
    guard !capture.isSwitchingCamera else { return }
    impactFeedback()
    button.startProcessing()
    capture.capturePhoto()
  }

  func captureButtonDidBeganLongPress(_: CaptureButton) {
    impactFeedback()
    toolView.hideButtons(animated: true)
    previewView.hideToolMask(animated: true)
    tipsView.hideTips(afterDelay: 0, animated: true)
    recorder.preferredAudioSettings = capture.recommendedAudioSetting
    recorder.preferredVideoSettings = capture.recommendedVideoSetting
    recorder.startRunning()
  }

  func captureButtonDidEndedLongPress(_ button: CaptureButton) {
    if recorder.isRunning {
      recorder.stopRunning()
      button.startProcessing()
    }
  }
}

// MARK: CapturePreviewViewDelegate

extension CaptureViewController: CapturePreviewViewDelegate {
  func previewView(_: CapturePreviewView, didFocusAt point: CGPoint) {
    capture.focus(at: point)
    capture.exposure(at: point)
  }

  func previewView(_: CapturePreviewView, didUpdateExposure level: CGFloat) {
    capture.exposure(bias: 1 - level)
  }

  func previewView(_: CapturePreviewView, didPinchWith scale: CGFloat) {
    capture.zoom(scale)
  }
}

// MARK: CaptureDelegate

extension CaptureViewController: CaptureDelegate {
  func captureDidCapturePhoto(_: Capture) {
    previewView.isRunning = false
  }

  func captureDidChangeSubjectArea(_ capture: Capture) {
    previewView.autoFocus()
    capture.focus()
    capture.exposure()
  }

  func capture(_: Capture, didUpdate _: AudioIOComponent.ObservableProperty) { }

  func capture(_: Capture, didUpdate _: VideoIOComponent.ObservableProperty) { }

  func capture(_: Capture, didOutput photoData: Data, fileType: FileType) {
    trackObserver?.track(event: .capturePhoto, userInfo: [:])
    guard UIDevice.current.userInterfaceIdiom == .phone else {
      if let url = FileHelper.write(photoData: photoData, fileType: fileType) {
        toolView.captureButton.stopProcessing()
        delegate?.capture(self, didOutput: url, type: .photo)
      }
      return
    }

    #if ANYIMAGEKIT_ENABLE_EDITOR
    guard let image = UIImage(data: photoData) else { return }
    var editorOptions = options.editorPhotoOptions
    editorOptions.enableDebugLog = options.enableDebugLog
    let controller = ImageEditorController(photo: image, options: editorOptions, delegate: self)
    present(controller, animated: false) { [weak self] in
      guard let self else { return }
      toolView.captureButton.stopProcessing()
      capture.stopRunning()
      orientationUtil.stopRunning()
    }
    #else
    if let url = FileHelper.write(photoData: photoData, utType: fileType.utType) {
      delegate?.capture(self, didOutput: url, type: .photo)
    }
    #endif
  }

  func capture(_: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType) {
    switch type {
    case .audio:
      recorder.append(sampleBuffer: sampleBuffer, mediaType: .audio)
    case .video:
      recorder.append(sampleBuffer: sampleBuffer, mediaType: .video)
      previewView.draw(sampleBuffer)
    }
  }
}

// MARK: RecorderDelegate

extension CaptureViewController: RecorderDelegate {
  func recorder(_: Recorder, didCreateMovieFileAt url: URL, thumbnail: UIImage?) {
    trackObserver?.track(event: .captureVideo, userInfo: [:])
    toolView.showButtons(animated: true)
    previewView.showToolMask(animated: true)

    guard UIDevice.current.userInterfaceIdiom == .phone else {
      toolView.captureButton.stopProcessing()
      delegate?.capture(self, didOutput: url, type: .video)
      return
    }

    #if ANYIMAGEKIT_ENABLE_EDITOR
    var editorOptions = options.editorVideoOptions
    editorOptions.enableDebugLog = options.enableDebugLog
    let controller = ImageEditorController(
      video: url,
      placeholderImage: thumbnail,
      options: editorOptions,
      delegate: self)
    present(controller, animated: false) { [weak self] in
      guard let self else { return }
      toolView.captureButton.stopProcessing()
      capture.stopRunning()
      orientationUtil.stopRunning()
    }
    #else
    delegate?.capture(self, didOutput: url, type: .video)
    #endif
  }
}

// MARK: DeviceOrientationUtilDelegate

extension CaptureViewController: DeviceOrientationUtilDelegate {
  func device(_: DeviceOrientationUtil, didUpdate orientation: DeviceOrientation) {
    capture.orientation = orientation
    recorder.orientation = orientation
    toolView.rotate(to: orientation, animated: true)
    previewView.rotate(to: orientation, animated: true)
  }
}

#if ANYIMAGEKIT_ENABLE_EDITOR

// MARK: - ImageEditorControllerDelegate

extension CaptureViewController: ImageEditorControllerDelegate {
  func imageEditorDidCancel(_ editor: ImageEditorController) {
    capture.startRunning()
    orientationUtil.startRunning()
    previewView.isRunning = true
    editor.dismiss(animated: false, completion: nil)
  }

  func imageEditor(_: ImageEditorController, didFinishEditing result: EditorResult) {
    delegate?.capture(self, didOutput: result.mediaURL, type: result.type)
  }
}

#endif
