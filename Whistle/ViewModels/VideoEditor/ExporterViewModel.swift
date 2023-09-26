//
//  ExporterViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Combine
import Foundation
import Photos
import SwiftUI
import UIKit

class ExporterViewModel: ObservableObject {
  let video: EditableVideo

  @Published var renderState: ExportState = .unknown
  @Published var showAlert = false
  @Published var progressTimer: TimeInterval = .zero
  @Published var selectedQuality: VideoQuality = .medium
  private var cancellable = Set<AnyCancellable>()
  private var action: ActionEnum = .save
  private let editorHelper = VideoEditor()
  private var timer: Timer?

  init(video: EditableVideo) {
    self.video = video
    startRenderStateSubs()
  }

  deinit {
    cancellable.forEach { $0.cancel() }
    resetTimer()
  }

  @MainActor
  private func renderVideo() async {
    renderState = .loading
    do {
      let url = try await editorHelper.startRender(video: video, videoQuality: selectedQuality)
      renderState = .loaded(url)
    } catch {
      renderState = .failed(error)
    }
  }

  func action(_ action: ActionEnum) async {
    self.action = action
    await renderVideo()
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
            saveVideoInLib(url)
          } else {
            showShareSheet(data: url)
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

  private func showShareSheet(data: Any) {
    DispatchQueue.main.async {
      self.renderState = .unknown
    }
    UIActivityViewController(activityItems: [data], applicationActivities: nil).presentInKeyWindow()
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
      case .failed: return 3
      case .saved: return 4
      }
    }

    static func == (lhs: ExporterViewModel.ExportState, rhs: ExporterViewModel.ExportState) -> Bool {
      lhs.id == rhs.id
    }
  }
}