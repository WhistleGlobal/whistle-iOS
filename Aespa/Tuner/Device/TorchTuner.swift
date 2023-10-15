//
//  TorchTuner.swift
//
//
//  Created by 이영빈 on 2023/06/17.
//

import AVFoundation
import Foundation

struct TorchTuner: AespaDeviceTuning {
  let level: Float
  let torchMode: AVCaptureDevice.TorchMode

  func tune(_ device: some AespaCaptureDeviceRepresentable) throws {
    guard device.hasTorch else {
      throw AespaError.device(reason: .notSupported)
    }

    device.torchMode(torchMode)
    try device.setTorchModeOn(level: level)
  }
}
