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
  @Published var selectedQuality: VideoQuality = .low
  private var cancellable = Set<AnyCancellable>()
  private var action: ActionEnum = .save
  private let editorHelper = VideoEditor()
  private var timer: Timer?
  var base64String = ""
  var videoData = Data()
  init(video: EditableVideo) {
    self.video = video
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
      let url = try await editorHelper.startRender(video: video, videoQuality: selectedQuality, start: start)
      if let videoData = try? Data(contentsOf: url) {
        self.videoData = videoData
        base64String = videoData.base64EncodedString()
//        return base64String
        // base64String을 사용하거나 전송하려는 곳에 전달할 수 있습니다.
      }
      renderState = .loaded(url)
    } catch {
      renderState = .failed(error)
    }
//    return ""
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
      case .failed(let error):
        print("Fail Error", error)
        return 3
      case .saved: return 4
      }
    }

    static func == (lhs: ExporterViewModel.ExportState, rhs: ExporterViewModel.ExportState) -> Bool {
      lhs.id == rhs.id
    }
  }
}
