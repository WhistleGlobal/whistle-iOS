//
//  VideoStabilizationTuner.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation

struct VideoStabilizationTuner: AespaConnectionTuning {
  var stabilzationMode: AVCaptureVideoStabilizationMode

  func tune(_ connection: some AespaCaptureConnectionRepresentable) {
    connection.stabilizationMode(to: stabilzationMode)
  }
}
