//
//  AVCaptureFileOutput+AespaFileOutputRepresentable.swift
//
//
//  Created by 이영빈 on 2023/06/16.
//

import AVFoundation
import Foundation

// MARK: - AespaFileOutputRepresentable

protocol AespaFileOutputRepresentable {
  func stopRecording()
  func startRecording(
    to outputFileURL: URL,
    recordingDelegate delegate: AVCaptureFileOutputRecordingDelegate)
  func getConnection(with mediaType: AVMediaType) -> AespaCaptureConnectionRepresentable?
}

// MARK: - AVCaptureFileOutput + AespaFileOutputRepresentable

extension AVCaptureFileOutput: AespaFileOutputRepresentable {
  func getConnection(with mediaType: AVMediaType) -> AespaCaptureConnectionRepresentable? {
    connection(with: mediaType)
  }
}
