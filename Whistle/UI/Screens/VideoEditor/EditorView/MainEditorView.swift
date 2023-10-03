//
//  MainEditorView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import PhotosUI
import SnapKit
import SwiftUI

// MARK: - MainEditorView

struct MainEditorView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.dismiss) private var dismiss
  var project: ProjectEntity?
  var selectedVideoURL: URL?
  @State var isFullScreen = false
  @State var showVideoQualitySheet = false
  @StateObject var editorVM = EditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        VStack(spacing: 0) {
          CustomNavigationBarViewController(title: "새 게시물") {
            dismiss()
          }
          .frame(height: UIScreen.getHeight(54))
          PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer)

          ThumbnailsSliderView(
            currentTime: $videoPlayer.currentTime,
            video: $editorVM.currentVideo,
            editorVM: editorVM,
            videoPlayer: videoPlayer)
          {
            videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
            editorVM.setTools()
          }

          ToolsSectionView(videoPlayer: videoPlayer, editorVM: editorVM)
            .border(.yellow, width: 10)
            .opacity(isFullScreen ? 0 : 1)
            .padding(.top, 5)
        }
        .onAppear {
          setVideo(proxy)
        }
      }

      if showVideoQualitySheet, let video = editorVM.currentVideo {
        VideoExporterBottomSheetView(isPresented: $showVideoQualitySheet, video: video)
      }
    }
    .background(Color.Background_Default_Dark)
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
//    .ignoresSafeArea(.all)
    .onChange(of: scenePhase) { phase in
      saveProject(phase)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .overlay { }
  }
}

extension MainEditorView {
  private var headerView: some View {
    HStack {
//      Button {
//        editorVM.updateProject()
//        dismiss()
//      } label: {
//        Image(systemName: "folder.fill")
//      }
//
//      Spacer()
      Button {
        editorVM.selectedTools = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          showVideoQualitySheet.toggle()
        }
      } label: {
        Image(systemName: "square.and.arrow.up.fill")
      }
    }
    .foregroundColor(.white)
    .frame(height: 50)
  }

  private func saveProject(_ phase: ScenePhase) {
    switch phase {
    case .background, .inactive:
      editorVM.updateProject()
    default:
      break
    }
  }

  private func setVideo(_ proxy: GeometryProxy) {
    if let selectedVideoURL {
      videoPlayer.loadState = .loaded(selectedVideoURL)
      editorVM.setNewVideo(selectedVideoURL, geo: proxy)
    }

    if let project, let url = project.videoURL {
      videoPlayer.loadState = .loaded(url)
      editorVM.setProject(project, geo: proxy)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        videoPlayer.setFilters(
          mainFilter: CIFilter(name: project.filterName ?? ""),
          colorCorrection: editorVM.currentVideo?.colorCorrection)
      }
    }
  }
}
