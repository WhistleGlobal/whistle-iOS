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
            goUpload = true
          }
          .frame(height: UIScreen.getHeight(44))
          NavigationLink(destination: UploadView(editorVM: editorVM, videoPlayer: videoPlayer), isActive: $goUpload) {
            EmptyView()
          }
//          NavigationLink(destination: UploadView(editorVM: editorVM, videoPlayer: videoPlayer)) {
//            Rectangle().fill(.red)
//              .frame(width: 100, height: 100)
//          }
          ZStack(alignment: .top) {
            PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer, musicVM: musicVM)
            musicInfo()
          }
          .padding(.top, 4)

          ThumbnailsSliderView(
            currentTime: $videoPlayer.currentTime,
            video: $editorVM.currentVideo,
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
          setVideo(proxy)
        }
      }

      if showVideoQualitySheet, let video = editorVM.currentVideo {
        VideoExporterBottomSheetView(isPresented: $showVideoQualitySheet, video: video)
      }
    }
//    .navigationDestination(isPresented: $goUpload, destination: {
//      UploadView(editorVM: editorVM, videoPlayer: videoPlayer)
//    })
//    .onAppear {
//      // 비디오 파일 및 오디오 파일 경로 설정
//      let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
//      let audioURL = Bundle.main.url(forResource: "audio", withExtension: "mp3")!
//
//      // 비디오 및 오디오 asset 생성
//      let videoAsset = AVAsset(url: videoURL)
//      let audioAsset = AVAsset(url: audioURL)
//
//      // 비디오 트랙 및 오디오 트랙 생성
//      let videoTrack = videoAsset.tracks(withMediaType: .video)[0]
//      let audioTrack = audioAsset.tracks(withMediaType: .audio)[0]
//
//      // 합성을 위한 뮤터블 컴포지션 생성
//      let composition = AVMutableComposition()
//
//      // 비디오 트랙 및 오디오 트랙 추가
//      let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//      let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//
//      do {
//        // 비디오 트랙 및 오디오 트랙에 콘텐츠 추가
//        try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)
//        try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: audioTrack, at: .zero)
//
//        // 비디오와 오디오 합성 믹서 생성
//        let videoMix = AVMutableVideoComposition()
//        videoMix.frameDuration = CMTimeMake(value: 1, timescale: 30) // 프레임 속도 설정
//        videoMix.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
//
//        // 합성 레이어 설정
//        let videoLayer = CALayer()
//        let parentLayer = CALayer()
//
//        parentLayer.frame = CGRect(x: 0, y: 0, width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
//        videoLayer.frame = parentLayer.frame
//        parentLayer.addSublayer(videoLayer)
//
//        videoMix.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
//
//        // 합성 된 비디오 컴포지션 생성
//        let videoComposition = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
//        videoComposition?.outputFileType = .mp4
//        videoComposition?.outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
//        videoComposition?.videoComposition = videoMix
//
//        // 합성 실행
//        videoComposition?.exportAsynchronously {
//          DispatchQueue.main.async {
//            if let outputURL = videoComposition?.outputURL {
//              self.videoPlayer = AVPlayer(url: outputURL)
//            }
//          }
//        }
//      } catch {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
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
          }
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
