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

  @Published var recordedVideoURL: URL?

  override init() {
    session = AVCaptureSession()

    super.init()

    Task(priority: .background) {
      switch await AuthorizationChecker.checkCaptureAuthorizationStatus() {
      case .permitted:
        try? session
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

//  func toggleCameraDirection() {
//    // 카메라 전환을 비동기로 수행
//    Task {
//      await switchCameraDirection()
//    }
//  }
//
//  @MainActor
//  private func switchCameraDirection() {
//    guard let currentVideoInput = session.inputs.first as? AVCaptureDeviceInput else {
//      print("No video inputs found.")
//      return
//    }
//
//    let currentPosition = currentVideoInput.device.position
//    let newCameraPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
//
//    if let newVideoDevice = AVCaptureDevice.DiscoverySession(
//      deviceTypes: [.builtInWideAngleCamera],
//      mediaType: .video,
//      position: newCameraPosition).devices.first
//    {
//      do {
//        let newVideoInput = try AVCaptureDeviceInput(device: newVideoDevice)
//
//        session.beginConfiguration()
//        session.removeInput(currentVideoInput)
//        if session.canAddInput(newVideoInput) {
//          session.addInput(newVideoInput)
//        } else {
//          print("Could not add the new video input to the session")
//        }
//        session.commitConfiguration()
//      } catch {
//        print("Error creating AVCaptureDeviceInput: \(error)")
//      }
//    }
//  }

  func toggleCameraDirection() {
    guard let currentVideoInput = session.inputs.first as? AVCaptureDeviceInput else {
      print("No video inputs found.")
      return
    }

    // 현재 카메라 장치의 위치를 확인합니다.
    let currentPosition = currentVideoInput.device.position

    // 새로운 카메라 위치를 설정합니다.
    let newCameraPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

    // 사용 가능한 카메라 장치들 중에서 새로운 카메라 위치에 해당하는 장치를 찾습니다.
    if
      let newVideoDevice = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: newCameraPosition).devices.first
    {
      do {
        let newVideoInput = try AVCaptureDeviceInput(device: newVideoDevice)

        // 설정 변경을 시작합니다.
        session.beginConfiguration()

        // 기존의 비디오 입력을 제거하고 새로운 비디오 입력을 추가합니다.
        session.removeInput(currentVideoInput)
        if session.canAddInput(newVideoInput) {
          session.addInput(newVideoInput)
        } else {
          print("Could not add the new video input to the session")
        }

        // 설정 변경을 완료합니다.
        session.commitConfiguration()
      } catch {
        print("Error creating AVCaptureDeviceInput: \(error)")
      }
    }
  }

}

// MARK: AVCaptureFileOutputRecordingDelegate

extension ShootCameraViewModel: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(
    _: AVCaptureFileOutput,
    didFinishRecordingTo outputFileURL: URL,
    from _: [AVCaptureConnection],
    error _: Error?)
  {
    print("영상 촬영 완료!")
    recordedVideoURL = outputFileURL
  }
}

extension AVCaptureSession {
  var movieFileOutput: AVCaptureMovieFileOutput? {
    let output = outputs.first as? AVCaptureMovieFileOutput
    return output
  }

  func addMovieInput() throws -> Self {
    guard let videoDevice = AVCaptureDevice.default(for: .video) else {
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
