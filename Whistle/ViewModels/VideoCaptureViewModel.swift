//
//  VideoConentViewModel.swift
//  TestCamera
//
//  Created by ChoiYujin on 10/11/23.
//

import Aespa
import AVFoundation
import Combine
import Foundation
import SwiftUI

// MARK: - VideoCaptureViewModel

class VideoCaptureViewModel: ObservableObject {
  var aespaSession: AespaSession

  @Published var preview: InteractivePreview?
  @Published var videoFiles: [VideoAssetModel] = []
  @Published var photoFiles: [PhotoAssetModel] = []

  init() {
    let option = AespaOption(albumName: "Whistle")
    aespaSession = Aespa.session(with: option)
    preview = aespaSession.interactivePreview()

    // Common setting
    aespaSession
      .focus(mode: .autoFocus)
      .changeMonitoring(enabled: true)
      .orientation(to: .portrait)
      .quality(to: .high)
      .custom(WideColorCameraTuner()) { result in
        if case .failure(let error) = result {
          print("Error: ", error)
        }
      }
      .unmute()
      .stabilization(mode: .auto)
  }
}

// MARK: VideoCaptureViewModel.WideColorCameraTuner

extension VideoCaptureViewModel {
  // Example for using custom session tuner
  struct WideColorCameraTuner: AespaSessionTuning {
    func tune(_ session: some AespaCoreSessionRepresentable) throws {
      session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
    }
  }
}
