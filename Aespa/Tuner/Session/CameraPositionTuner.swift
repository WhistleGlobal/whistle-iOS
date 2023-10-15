//
//  CameraPositionTuner.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation

struct CameraPositionTuner: AespaSessionTuning {
  let needTransaction = true
  var position: AVCaptureDevice.Position
  var devicePreference: AVCaptureDevice.DeviceType?

  init(position: AVCaptureDevice.Position, devicePreference: AVCaptureDevice.DeviceType? = nil) {
    self.position = position
    self.devicePreference = devicePreference
  }

  func tune(_ session: some AespaCoreSessionRepresentable) throws {
    try session.cameraPosition(to: position, device: devicePreference)
  }
}
