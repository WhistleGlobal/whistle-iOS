//
//  MainEditorView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import BottomSheet
import PhotosUI
import SnapKit
import SwiftUI

// MARK: - MainEditorView

struct MainEditorView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.dismiss) private var dismiss
  var project: ProjectEntity?
  var selectedVideoURL: URL?
  @State var isInitial = true
  @State var isFullScreen = false
  @State var showVideoQualitySheet = false
  @State var isShowingMusicTrimView = false
  @State var bottomSheetTitle = ""
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var sheetPositions: [BottomSheetPosition] = [.hidden, .dynamic]
  @State var goUpload = false
  @StateObject var musicVM = MusicViewModel()
  @StateObject var editorVM = EditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        VStack(spacing: 0) {
          CustomNavigationBarViewController(title: "새 게시물") {
            dismiss()
          } nextButtonAction: {
            if let video = editorVM.currentVideo {
              if videoPlayer.isPlaying {
                videoPlayer.action(video)
              }
            }
            goUpload = true
          }
          .frame(height: UIScreen.getHeight(44))
          if let video = editorVM.currentVideo {
            NavigationLink(
              destination: UploadView(
                video: video,
                editorVM: editorVM,
                videoPlayer: videoPlayer,
                musicVM: musicVM,
                isInitial: $isInitial),
              isActive: $goUpload)
            {
              EmptyView()
            }
          }
          ZStack(alignment: .top) {
            PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer, musicVM: musicVM)
            musicInfo()
          }
          .padding(.top, 4)

          ThumbnailsSliderView(
            currentTime: $videoPlayer.currentTime,
            video: $editorVM.currentVideo,
            isInitial: $isInitial,
            editorVM: editorVM,
            videoPlayer: videoPlayer)
          {
            videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
            editorVM.setTools()
          }
          helpText

          ToolsSectionView(videoPlayer: videoPlayer, editorVM: editorVM)
        }
        .onAppear {
          if isInitial {
            setVideo(proxy)
          }
        }
      }

      if showVideoQualitySheet, let video = editorVM.currentVideo {
        VideoExporterBottomSheetView(isPresented: $showVideoQualitySheet, video: video)
      }
    }
    .background(Color.Background_Default_Dark)
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    .fullScreenCover(isPresented: $isShowingMusicTrimView) {
      MusicTrimView(
        musicVM: musicVM,
        editorVM: editorVM,
        videoPlayer: videoPlayer,
        isShowingMusicTrimView: $isShowingMusicTrimView)
    }
    .onChange(of: scenePhase) { phase in
      saveProject(phase)
    }
    .onChange(of: editorVM.selectedTools) { newValue in
      switch newValue {
      //      case .speed:
      //        bottomSheetPosition = .dynamic
      //        bottomSheetTitle = "영상 속도"
      case .music:
        if let video = editorVM.currentVideo {
          if videoPlayer.isPlaying {
            videoPlayer.action(video)
          }
          videoPlayer.scrubState = .scrubEnded(video.rangeDuration.lowerBound)
        }
        bottomSheetPosition = .relative(1)
        sheetPositions = [.absolute(UIScreen.getHeight(400)), .hidden, .relative(1)]
        bottomSheetTitle = "음악 검색"
      case .audio:
        bottomSheetPosition = .dynamic
        sheetPositions = [.hidden, .dynamic]
        bottomSheetTitle = "볼륨 조절"
      //      case .filters: print("filters")
      //      case .corrections: print("corrections")
      //      case .frames: print("frames")
      case nil: print("nil")
      }
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: sheetPositions)
    {
      VStack(spacing: 0) {
        ZStack {
          Text(bottomSheetTitle)
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .hCenter()
          Text("취소")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .contentShape(Rectangle())
            .hTrailing()
            .onTapGesture {
              bottomSheetPosition = .hidden
              editorVM.selectedTools = nil
            }
        }
        .foregroundStyle(Color.White)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        Rectangle()
          .fill(Color.Border_Default_Dark)
          .frame(height: 1)
      }
    } mainContent: {
      switch editorVM.selectedTools {
      //      case .speed:
      //        if let toolState = editorVM.selectedTools, let video = editorVM.currentVideo {
      //          let isAppliedTool = video.isAppliedTool(for: toolState)
      //          VStack {
      //            VideoSpeedSlider(value: Double(video.rate), isChangeState: isAppliedTool) { rate in
      //              videoPlayer.pause()
      //              editorVM.updateRate(rate: rate)
      //              print("range: \(editorVM.currentVideo?.rangeDuration)")
      //            }
      //            Text("속도 설정")
      //              .fontSystem(fontDesignSystem: .subtitle2_KO)
      //              .foregroundColor(.white)
      //              .padding(.horizontal, UIScreen.getWidth(150))
      //              .padding(.vertical, UIScreen.getHeight(12))
      //              .background(RoundedRectangle(cornerRadius: 100).fill(Color.Blue_Default))
      //              .onTapGesture {
      //                bottomSheetPosition = .hidden
      //                editorVM.selectedTools = nil
      //              }
      //              .padding(.top, UIScreen.getHeight(36))
      //          }
      //        }
      case .music:
        MusicListView(
          musicVM: musicVM,
          editorVM: editorVM,
          videoPlayer: videoPlayer,
          bottomSheetPosition: $bottomSheetPosition,
          isShowingMusicTrimView: $isShowingMusicTrimView)
        {
          bottomSheetPosition = .relative(1)
        }
      case .audio:
        AudioSheetView(videoPlayer: videoPlayer, editorVM: editorVM, musicVM: musicVM) {
          bottomSheetPosition = .hidden
          editorVM.selectedTools = nil
        }
      //        case .filters: print("filters")
      //        case .corrections: print("corrections")
      //        case .frames: print("frames")
      //        case nil: print("nil")
      default: Text("")
      }
    }
    .onDismiss {
      editorVM.selectedTools = nil
    }
    .enableSwipeToDismiss()
    .enableTapToDismiss()
    .customBackground(
      glassMorphicView(width: UIScreen.width, height: .infinity, cornerRadius: 24)
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(LinearGradient.Border_Glass)))
    .showDragIndicator(true)
    .dragIndicatorColor(Color.Border_Default_Dark)
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

  private var helpText: some View {
    Text("최소 1초, 최대 15초 동영상을 올릴 수 있어요.")
      .foregroundStyle(Color.white)
      .fontSystem(fontDesignSystem: .body2_KO)
      .padding(.vertical, 32)
  }

  private func saveProject(_ phase: ScenePhase) {
    switch phase {
    case .background, .inactive:
      editorVM.updateProject()
    default:
      break
    }
  }

  @ViewBuilder
  private func musicInfo() -> some View {
    if let music = musicVM.musicInfo {
      HStack(spacing: 12) {
        Image(systemName: "music.note")
        Text(music.musicTitle)
          .frame(maxWidth: UIScreen.getWidth(90))
          .lineLimit(1)
          .truncationMode(.tail)
          .fontSystem(fontDesignSystem: .body1)
          .contentShape(Rectangle())
          .onTapGesture {
            isShowingMusicTrimView = true
          }
        Divider()
          .overlay { Color.White }
        Image(systemName: "xmark")
          .contentShape(Rectangle())
          .onTapGesture {
            musicVM.removeMusic()
            editorVM.removeAudio()
          }
      }
      .foregroundStyle(Color.White)
      .fixedSize()
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(glassMorphicView(cornerRadius: 8))
      .padding(.top, 8)
    } else {
      HStack {
        Image(systemName: "music.note")
        Text("음악 추가")
          .frame(maxWidth: UIScreen.getWidth(90))
          .lineLimit(1)
          .truncationMode(.tail)
          .fontSystem(fontDesignSystem: .body1)
          .contentShape(Rectangle())
      }
      .foregroundStyle(Color.White)
      .fixedSize()
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(glassMorphicView(cornerRadius: 8))
      .padding(.top, 8)
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
