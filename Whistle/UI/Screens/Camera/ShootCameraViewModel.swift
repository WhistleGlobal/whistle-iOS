//
//  ShootCameraViewModel.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import AVFoundation
import Foundation
import Photos

// MARK: - ShootCameraViewModel

class ShootCameraViewModel: NSObject, ObservableObject {
  let session: AVCaptureSession
  @Published var preview: Preview?

    // 인트 추가
    @Published var recordedVideoURL: URL?

  override init() {
    session = AVCaptureSession()

    super.init()

    Task(priority: .background) {
      switch await AuthorizationChecker.checkCaptureAuthorizationStatus() {
      case .permitted:
        try session
          .addMovieInput()
          .addMovieFileOutput()
          .startRunning()

        DispatchQueue.main.async {
          self.preview = Preview(session: self.session, gravity: .resizeAspectFill)
        }

      case .notPermitted:
        break
      }
    }
  }

  func startRecording() {
    guard let output = session.movieFileOutput else {
      print("Cannot find movie file output")
      return
    }

    guard
      let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      print("Cannot access local file domain")
      return
    }

    let fileName = UUID().uuidString

    let filePath = directoryPath
      .appendingPathComponent(fileName)
      .appendingPathExtension("mp4")

    output.startRecording(to: filePath, recordingDelegate: self)
  }

  func stopRecording() {
    guard let output = session.movieFileOutput else {
      print("Cannot find movie file output")
      return
    }

    output.stopRecording()
  }
}

// MARK: AVCaptureFileOutputRecordingDelegate

// 인트 수정
extension ShootCameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from _: [AVCaptureConnection],
        error _: Error?)
      {
        print("영상 촬영 완료!")
        recordedVideoURL = outputFileURL  // 촬영된 영상의 URL 저장
      }
}



extension AVCaptureSession {
  var movieFileOutput: AVCaptureMovieFileOutput? {
    let output = outputs.first as? AVCaptureMovieFileOutput

    return output
  }

  func addMovieInput() throws -> Self {
    // Add video input
    guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    let videoInput = try AVCaptureDeviceInput(device: videoDevice)
    guard canAddInput(videoInput) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    addInput(videoInput)

    return self
  }

  func addMovieFileOutput() throws -> Self {
    guard movieFileOutput == nil else {
      // return itself if output is already set
      return self
    }

    let fileOutput = AVCaptureMovieFileOutput()
    guard canAddOutput(fileOutput) else {
      throw VideoError.device(reason: .unableToSetOutput)
    }

    addOutput(fileOutput)

    return self
  }
}
