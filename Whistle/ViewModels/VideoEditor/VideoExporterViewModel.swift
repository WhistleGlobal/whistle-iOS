//
//  VideoExporterViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Combine
import Foundation
import Photos
import SwiftUI
import UIKit

class VideoExporterViewModel: ObservableObject {
  let video: EditableVideo
  let musicVolume: Float

  @Published var renderState: ExportState = .unknown
  @Published var showAlert = false
  @Published var progressTimer: TimeInterval = .zero
  @Published var selectedQuality: VideoQuality = .high
  private var cancellable = Set<AnyCancellable>()
  private var action: ActionEnum = .save
  private let editorHelper = VideoEditor()
  private var timer: Timer?
  var videoData = Data()
  init(video: EditableVideo, musicVolume: Float) {
    self.video = video
    self.musicVolume = musicVolume
    startRenderStateSubs()
  }

  deinit {
    cancellable.forEach { $0.cancel() }
    resetTimer()
  }

  @MainActor
  private func renderVideo(start: Double) async {
    renderState = .loading
    do {
      let url = try await editorHelper.startRender(
        video: video,
        videoQuality: selectedQuality,
        start: start,
        musicVolume: musicVolume)
      if let videoData = try? Data(contentsOf: url) {
        self.videoData = videoData
      }
      renderState = .loaded(url)
    } catch {
      renderState = .failed(error)
    }
  }

  func action(_ action: ActionEnum, start: Double) async {
    self.action = action
//    return await renderVideo(start: start)
    await renderVideo(start: start)
  }

  private func startRenderStateSubs() {
    $renderState
      .sink { [weak self] state in
        guard let self else { return }
        switch state {
        case .loading:
          timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.progressTimer += 1
          }
        case .loaded(let url):
          if action == .save {
            renderState = .saved
            saveVideoInLib(url)
          }
          resetTimer()
        default:
          break
        }
      }
      .store(in: &cancellable)
  }

  private func resetTimer() {
    timer?.invalidate()
    timer = nil
    progressTimer = .zero
  }

  private func saveVideoInLib(_ url: URL) {
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
    }) { [weak self] saved, _ in
      guard let self else { return }
      if saved {
        DispatchQueue.main.async {
          self.renderState = .saved
        }
      }
    }
  }

  enum ActionEnum: Int {
    case save, share
  }

  enum ExportState: Identifiable, Equatable {
    case unknown, loading, loaded(URL), failed(Error), saved

    var id: Int {
      switch self {
      case .unknown: return 0
      case .loading: return 1
      case .loaded: return 2
      case .failed(let error):
        WhistleLogger.logger.debug("Error: \(error)")
        return 3
      case .saved: return 4
      }
    }

    static func == (lhs: VideoExporterViewModel.ExportState, rhs: VideoExporterViewModel.ExportState) -> Bool {
      lhs.id == rhs.id
    }
  }
}
