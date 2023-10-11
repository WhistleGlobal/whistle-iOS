//
//  VideoConentViewModel.swift
//  TestCamera
//
//  Created by ChoiYujin on 10/11/23.
//

import Combine
import Foundation
import SwiftUI

import Aespa

// MARK: - VideoContentViewModel

class VideoContentViewModel: ObservableObject {
  let aespaSession: AespaSession

  var preview: some View {
    aespaSession.interactivePreview()
  }

  private var subscription = Set<AnyCancellable>()

  @Published var videoAlbumCover: Image?
  @Published var photoAlbumCover: Image?

  @Published var videoFiles: [VideoAssetModel] = []
  @Published var photoFiles: [PhotoAssetModel] = []

  init() {
    let option = AespaOption(albumName: "Whistle")
    aespaSession = Aespa.session(with: option)

    // Common setting
    aespaSession
      .focus(mode: .locked)
      .changeMonitoring(enabled: true)
      .orientation(to: .portrait)
      .quality(to: .high)
      .custom(WideColorCameraTuner()) { result in
        if case .failure(let error) = result {
          print("Error: ", error)
        }
      }

    aespaSession
      .stabilization(mode: .auto)

    aespaSession.videoFilePublisher
      .receive(on: DispatchQueue.main)
      .map { result -> Image? in
        if case .success(let file) = result {
          return file.thumbnailImage
        } else {
          return nil
        }
      }
      .assign(to: \.videoAlbumCover, on: self)
      .store(in: &subscription)

    aespaSession.photoFilePublisher
      .receive(on: DispatchQueue.main)
      .map { result -> Image? in
        if case .success(let file) = result {
          return file.thumbnailImage
        } else {
          return nil
        }
      }
      .assign(to: \.photoAlbumCover, on: self)
      .store(in: &subscription)
  }
}


// MARK: VideoContentViewModel.WideColorCameraTuner

extension VideoContentViewModel {
  // Example for using custom session tuner
  struct WideColorCameraTuner: AespaSessionTuning {
    func tune(_ session: some AespaCoreSessionRepresentable) throws {
      session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
    }
  }
}

