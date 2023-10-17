//
//  FinishRecordProcessor.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation

struct FinishRecordProcessor: AespaMovieFileOutputProcessing {
  func process(_ output: some AespaFileOutputRepresentable) throws {
    output.stopRecording()
  }
}
