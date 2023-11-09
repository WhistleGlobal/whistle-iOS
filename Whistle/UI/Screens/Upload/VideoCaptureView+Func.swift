//
//  VideoCaptureView+Func.swift
//  Whistle
//
//  Created by 박상원 on 11/10/23.
//

import Photos
import SwiftUI

extension VideoCaptureView {
  func toggleFlash() {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    if device.hasTorch {
      do {
        try device.lockForConfiguration()

        if device.torchMode == .on {
          device.torchMode = .off
          isFlashOn = false
        } else {
          try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
          isFlashOn = true
        }
        device.unlockForConfiguration()
      } catch {
        WhistleLogger.logger.debug("Flash could not be used")
      }
    } else {
      WhistleLogger.logger.debug("Device does not have a Torch")
    }
  }

  func startPreparingTimer() {
    count = CGFloat(selectedSec.0 == .sec3 ? 3 : 10)
    showPreparingView = true
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      if count <= 0 {
        showPreparingView = false
        selectedSec.0 = .sec3
        selectedSec.1 = false
        buttonState = .recording
        viewModel.aespaSession.startRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        startRecordingTimer()
        isRecording = true
      } else {
        withAnimation(.linear(duration: 0.1)) {
          count -= 0.1
        }
      }
    }
  }

  func startRecordingTimer() {
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      if recordingDuration >= Double(timerSec.1 ? Double(timerSec.0) : 15.0) {
        buttonState = .completed
        stopRecordingTimer()
        isRecording = false
        viewModel.aespaSession.stopRecording { result in
          switch result {
          case .success(let videoURL):
            setVideo(videoURL)
          case .failure(let error):
            WhistleLogger.logger.debug("Error: \(error)")
          }
        }
        recordingTimer?.invalidate() // 타이머 중지
        recordingTimer = nil
      } else {
        recordingDuration += 0.1
      }
    }
  }

  func stopRecordingTimer() {
    recordingTimer?.invalidate()
    recordingTimer = nil
    timerSec.0 = 15
    timerSec.1 = false
  }

  // 시간을 TimeInterval에서 "00:00" 형식의 문자열로 변환
  func timeStringFromTimeInterval(_ interval: TimeInterval) -> String {
    let minutes = Int(interval) / 60
    let seconds = Int(interval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  func setVideo(_ url: URL) {
    selectedVideoURL = url

    if let selectedVideoURL {
      videoPlayer.loadState = .loaded(selectedVideoURL)
      editorVM.setNewVideo(selectedVideoURL)
    }

    if let project, let url = project.videoURL {
      videoPlayer.loadState = .loaded(url)
      editorVM.setProject(project)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        videoPlayer.setFilters(
          mainFilter: CIFilter(name: project.filterName ?? ""),
          colorCorrection: editorVM.currentVideo?.colorCorrection)
      }
    }
  }

  func getAlbumAuth() {
    switch authorizationStatus {
    case .authorized:
      isAlbumAuthorized = true
    case .limited:
      isAlbumAuthorized = true
    default:
      break
    }
  }

  func fetchLatestVideo() -> PHAsset? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
    return fetchResult.firstObject
  }

  func generateThumbnail(for asset: PHAsset) -> UIImage? {
    let imageManager = PHCachingImageManager()
    let options = PHImageRequestOptions()
    options.isSynchronous = true

    var thumbnail: UIImage?
    imageManager.requestImage(
      for: asset,
      targetSize: CGSize(width: 100, height: 100),
      contentMode: .aspectFill,
      options: options)
    { result, _ in
      thumbnail = result
    }
    return thumbnail
  }
}
