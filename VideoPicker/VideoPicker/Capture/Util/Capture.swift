//
//  Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - CaptureDelegate

protocol CaptureDelegate: AnyObject {
  func captureDidCapturePhoto(_ capture: Capture)
  func captureDidChangeSubjectArea(_ capture: Capture)
  func capture(_ capture: Capture, didUpdate audioProperty: AudioIOComponent.ObservableProperty)
  func capture(_ capture: Capture, didUpdate videoProperty: VideoIOComponent.ObservableProperty)
  func capture(_ capture: Capture, didOutput photoData: Data, fileType: FileType)
  func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType)
}

// MARK: - Capture

final class Capture {
  weak var delegate: CaptureDelegate?

  private let options: CaptureOptionsInfo
  private let session: AVCaptureSession
  private let audioIO: AudioIOComponent
  private let videoIO: VideoIOComponent

  var orientation: DeviceOrientation = .portrait
  var isSwitchingCamera = false

  init(options: CaptureOptionsInfo) {
    self.options = options
    session = AVCaptureSession()
    session.beginConfiguration()
    audioIO = AudioIOComponent(session: session, options: options)
    videoIO = VideoIOComponent(session: session, options: options)
    session.commitConfiguration()
    audioIO.delegate = self
    videoIO.delegate = self
  }
}

// MARK: - Session

extension Capture {
  func startRunning() {
    #if !targetEnvironment(simulator)
    DispatchQueue.global().async {
      self.session.startRunning()
    }
    #endif
  }

  func stopRunning() {
    #if !targetEnvironment(simulator)
    DispatchQueue.global().async {
      self.session.stopRunning()
    }
    #endif
  }
}

// MARK: - Camera

extension Capture {
  func startSwitchCamera() {
    isSwitchingCamera = true
    session.beginConfiguration()
    videoIO.switchCamera(session: session)
    session.commitConfiguration()
  }

  func stopSwitchCamera() -> CapturePosition {
    isSwitchingCamera = false
    return videoIO.position
  }

  func zoom(_ scale: CGFloat = 1.0) {
    var zoomFactor = videoIO.zoomFactor * scale
    let minZoomFactor = videoIO.minZoomFactor
    let maxZoomFactor = videoIO.maxZoomFactor
    if zoomFactor < minZoomFactor {
      zoomFactor = minZoomFactor
    }
    if zoomFactor > maxZoomFactor {
      zoomFactor = maxZoomFactor
    }
    videoIO.setZoomFactor(zoomFactor)
  }

  func focus(at point: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
    videoIO.setFocus(point: point)
  }

  func exposure(at point: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
    videoIO.setExposure(point: point)
  }

  func exposure(bias level: CGFloat) {
    let level = Float(level)
    let base: Float = 0.0
    if level < 0.5 { // [minExposureTargetBias, exposureBiasBaseline)
      let systemMin = videoIO.minExposureTargetBias
      let availableRange: Float = 0.5
      let min = systemMin + (base - systemMin) * availableRange
      let newBias = min + (base - min) * (level / 0.5)
      videoIO.setExposure(bias: newBias)
    } else { // [exposureBiasBaseline, maxExposureTargetBias]
      let systemMax = videoIO.maxExposureTargetBias
      let availableRange: Float = 0.4
      let max = base + (systemMax - base) * availableRange
      let newBias = base + (max - base) * ((level - 0.5) / 0.5)
      videoIO.setExposure(bias: newBias)
    }
  }
}

// MARK: - Photo

extension Capture {
  func capturePhoto() {
    videoIO.capturePhoto(orientation: orientation)
  }
}

// MARK: - Asset Writer Settings

extension Capture {
  var recommendedAudioSetting: [String: Any]? {
    audioIO.recommendedWriterSettings
  }

  var recommendedVideoSetting: [String: Any]? {
    videoIO.recommendedWriterSettings
  }
}

// MARK: AudioIOComponentDelegate

extension Capture: AudioIOComponentDelegate {
  func audioIO(_: AudioIOComponent, didUpdate property: AudioIOComponent.ObservableProperty) {
    delegate?.capture(self, didUpdate: property)
  }

  func audioIO(_: AudioIOComponent, didOutput sampleBuffer: CMSampleBuffer) {
    delegate?.capture(self, didOutput: sampleBuffer, type: .audio)
  }
}

// MARK: VideoIOComponentDelegate

extension Capture: VideoIOComponentDelegate {
  func videoIODidCapturePhoto(_: VideoIOComponent) {
    delegate?.captureDidCapturePhoto(self)
  }

  func videoIODidChangeSubjectArea(_: VideoIOComponent) {
    delegate?.captureDidChangeSubjectArea(self)
  }

  func videoIO(_: VideoIOComponent, didUpdate property: VideoIOComponent.ObservableProperty) {
    delegate?.capture(self, didUpdate: property)
  }

  func videoIO(_: VideoIOComponent, didOutput photoData: Data, fileType: FileType) {
    delegate?.capture(self, didOutput: photoData, fileType: fileType)
  }

  func videoIO(_: VideoIOComponent, didOutput sampleBuffer: CMSampleBuffer) {
    guard !isSwitchingCamera else { return }
    delegate?.capture(self, didOutput: sampleBuffer, type: .video)
  }
}
