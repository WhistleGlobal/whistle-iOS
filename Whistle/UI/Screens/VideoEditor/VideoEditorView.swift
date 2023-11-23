//
//  VideoEditorView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import BottomSheet
import PhotosUI
import SnapKit
import SwiftUI

// MARK: - VideoEditorView

struct VideoEditorView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.dismiss) private var dismiss
  @StateObject var musicVM = MusicViewModel()
  @StateObject var editorVM = VideoEditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()
  @StateObject var alertViewModel = AlertViewModel.shared

  @State var isInitial = true
  @State var goUpload = false
  @State var showMusicTrimView = false
  @State var showVideoQualitySheet = false
  @State var bottomSheetTitle: LocalizedStringKey = ""
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var sheetPositions: [BottomSheetPosition] = [.hidden, .dynamic]
  @State var thumbnail: Image?
  var project: ProjectEntity?
  var selectedVideoURL: URL?

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.Background_Default_Dark.ignoresSafeArea()
        VStack(spacing: 0) {
          CustomNavigationBarViewController(title: "새 게시물") {
            alertViewModel.stackAlert(
              isImmediateDismiss: true,
              title: AlertTitles().stopEditing,
              content: AlertContents().stopEditing,
              cancelText: AlertButtons().continueEditing,
              destructiveText: AlertButtons().stopEditing)
            {
              if let video = editorVM.currentVideo {
                if videoPlayer.isPlaying {
                  videoPlayer.action(video)
                }
              }
              dismiss()
            }
          } nextButtonAction: {
            if let video = editorVM.currentVideo {
              if videoPlayer.isPlaying {
                videoPlayer.action(video)
              }
              thumbnail = video.getThumbnail(start: video.rangeDuration.lowerBound)
            }
            goUpload = true
          }
          .frame(height: UIScreen.getHeight(44))
          if let video = editorVM.currentVideo {
            NavigationLink(
              destination: DescriptionEditorView(
                uploadMethod: .gallery,
                video: video,
                thumbnail: thumbnail,
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
            PlayerHolderView(editorVM: editorVM, videoPlayer: videoPlayer, musicVM: musicVM)
            if musicVM.isTrimmed {
              MusicInfo(musicVM: musicVM, showMusicTrimView: $showMusicTrimView) {
                showMusicTrimView = true
              } onDelete: {
                musicVM.removeMusic()
                editorVM.removeAudio()
              }
            }
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

          VideoEditorToolsSection(videoPlayer: videoPlayer, editorVM: editorVM)
        }
        .onAppear {
          alertViewModel.onFullScreenCover = true
          if isInitial {
            setVideo()
          }
        }
        .overlay {
          if alertViewModel.onFullScreenCover {
            AlertPopup()
          }
        }
      }
      .disableSwipeBack()
      .toolbar(.hidden)
      .background(Color.Background_Default_Dark)
      .ignoresSafeArea()
      .navigationBarHidden(true)
      .navigationBarBackButtonHidden(true)
      .fullScreenCover(isPresented: $showMusicTrimView) {
        MusicTrimView(
          musicVM: musicVM,
          editorVM: editorVM,
          videoPlayer: videoPlayer,
          showMusicTrimView: $showMusicTrimView)
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
          bottomSheetPosition = .relative(0.5)
          sheetPositions = [.relative(1), .hidden, .relative(0.5)]
          bottomSheetTitle = VideoEditorWords().searchMusic
        case .audio:
          bottomSheetPosition = .dynamic
          sheetPositions = [.hidden, .dynamic]
          bottomSheetTitle = VideoEditorWords().mutateVolume
        //      case .filters: print("filters")
        //      case .corrections: print("corrections")
        //      case .frames: print("frames")
        case nil: WhistleLogger.logger.debug("nil")
        }
      }
      .bottomSheet(
        bottomSheetPosition: $bottomSheetPosition,
        switchablePositions: sheetPositions)
      {
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
        //              .fontSystem(fontDesignSystem: .subtitle2)
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
            bottomSheetPosition: $bottomSheetPosition,
            showMusicTrimView: $showMusicTrimView)
        case .audio:
          VolumeSliderSheetView(
            videoPlayer: videoPlayer,
            editorVM: editorVM,
            musicVM: musicVM,
            bottomSheetPosition: $bottomSheetPosition)
          {
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
        glassMorphicView(cornerRadius: 24)
          .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(LinearGradient.Border_Glass)))
      .showDragIndicator(true)
      .dragIndicatorColor(Color.Border_Default_Dark)
    }
    .ignoresSafeArea(.keyboard)
  }
}

extension VideoEditorView {
  private var headerView: some View {
    HStack {
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
    Text(VideoEditorWords().editorComment)
      .foregroundStyle(Color.white)
      .fontSystem(fontDesignSystem: .body2)
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

  private func setVideo() {
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
}
