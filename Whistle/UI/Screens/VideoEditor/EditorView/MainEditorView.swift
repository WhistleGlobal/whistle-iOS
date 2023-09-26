//
//  MainEditorView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import PhotosUI
import SwiftUI

// MARK: - MainEditorView

struct MainEditorView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.dismiss) private var dismiss
  var project: ProjectEntity?
  var selectedVideoURl: URL?
  @State var isFullScreen = false
  @State var showVideoQualitySheet = false
  @StateObject var editorVM = EditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()
  var body: some View {
    ZStack {
      GeometryReader { proxy in
        VStack(spacing: 0) {
          headerView
          PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer)
          PlayerControl(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer)
          ToolsSectionView(videoPlayer: videoPlayer, editorVM: editorVM)
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
    .background(Color.black)
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    .ignoresSafeArea(.all, edges: .top)
    .statusBar(hidden: true)
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
      Button {
        editorVM.updateProject()
        dismiss()
      } label: {
        Image(systemName: "folder.fill")
      }

      Spacer()

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
    .padding(.horizontal, 20)
    .frame(height: 50)
    .padding(.bottom)
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
    if let selectedVideoURl {
      videoPlayer.loadState = .loaded(selectedVideoURl)
      editorVM.setNewVideo(selectedVideoURl, geo: proxy)
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
