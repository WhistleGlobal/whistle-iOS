//
//  AVCaptureConnection+AespaRepresentable.swift
//
//
//  Created by 이영빈 on 2023/06/16.
//

import AVFoundation
import Foundation

// MARK: - AespaCaptureConnectionRepresentable

protocol AespaCaptureConnectionRepresentable {
  var videoOrientation: AVCaptureVideoOrientation { get set }
  var preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode { get set }

  func orientation(to orientation: AVCaptureVideoOrientation)
  func stabilizationMode(to mode: AVCaptureVideoStabilizationMode)
}

// MARK: - AVCaptureConnection + AespaCaptureConnectionRepresentable

extension AVCaptureConnection: AespaCaptureConnectionRepresentable {
  func orientation(to orientation: AVCaptureVideoOrientation) {
    videoOrientation = orientation
  }

  func stabilizationMode(to mode: AVCaptureVideoStabilizationMode) {
    preferredVideoStabilizationMode = mode
  }
}
