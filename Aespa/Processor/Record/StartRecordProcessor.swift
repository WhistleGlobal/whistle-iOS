//
//  StartRecordProcessor.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation

struct StartRecordProcessor: AespaMovieFileOutputProcessing {
  let filePath: URL
  let delegate: AVCaptureFileOutputRecordingDelegate

  func process(_ output: some AespaFileOutputRepresentable) throws {
    guard output.getConnection(with: .video) != nil else {
      throw AespaError.session(reason: .cannotFindConnection)
    }

    output.startRecording(to: filePath, recordingDelegate: delegate)
  }
}
