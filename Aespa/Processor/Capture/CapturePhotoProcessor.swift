//
//  CapturePhotoProcessor.swift
//
//
//  Created by 이영빈 on 2023/06/18.
//

import AVFoundation

struct CapturePhotoProcessor: AespaCapturePhotoOutputProcessing {
  let setting: AVCapturePhotoSettings
  let delegate: AVCapturePhotoCaptureDelegate

  func process(_ output: some AespaPhotoOutputRepresentable) throws {
    guard output.getConnection(with: .video) != nil else {
      throw AespaError.session(reason: .cannotFindConnection)
    }

    output.capturePhoto(with: setting, delegate: delegate)
  }
}
