//
//  VideoContentView.swift
//  TestCamera
//
//  Created by ChoiYujin on 10/11/23.
//

import Aespa
import AVFoundation
import BottomSheet
import Combine
import Photos
import ReverseMask
import SwiftUI

// MARK: - VideoContentView

struct VideoContentView: View {
  // MARK: - Objects

  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @ObservedObject private var viewModel = VideoContentViewModel()
  @StateObject var editorVM = EditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()
  @StateObject var musicVM = MusicViewModel()

  @State var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State var isAlbumAuthorized = false
  @State var showAlbumAccessView = false

  // MARK: - Datas

  @State var isImagePickerClosed = PassthroughSubject<Bool, Never>()
  @State private var buttonState: CameraButtonState = .idle
  @State var captureMode: AssetType = .video
  @State var selectedSec = (SelectedSecond.sec3, false)
  @State private var recordingDuration: TimeInterval = 0
  @State private var recordingTimer: Timer?
  @State var selectedVideoURL: URL?
  @State var project: ProjectEntity?
  @State private var animatedProgress = 0.0
  @State var count: CGFloat = 0
  @State var dragOffset: CGFloat = 0
  @State var sheetPositions: [BottomSheetPosition] = [.hidden, .absolute(514)]
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var albumCover = Image("noVideo")

  // MARK: - Bools

  @State var disableUploadButton = false
  @State var isRecording = false
  @State var isFront = false
  @State var isFlashOn = false
  @State var showSetting = false
  @State var showGallery = false
  @State var showPreparingView = false
  @State var isPresented = false
  @State var timerSec = (8, false)
  /// 작업물 삭제 alert용
  @State var showAlert = false
  /// 음악 편집기 띄우기용
  @State var showMusicTrimView = false

  // MARK: - Computed

  var barSpacing: CGFloat {
    CGFloat((UIScreen.width - 32 - 12 - (14 * 6)) / 15)
  }

  var defaultWidth: CGFloat {
    CGFloat(6 + (6 + barSpacing) * 8)
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AlertPopup(
        alertStyle: .linear,
        title: "영상을 삭제하시겠어요?",
        content: "지금 돌아가면 변경 사항이 모두 삭제됩니다.",
        cancelText: "계속 수정",
        destructiveText: "삭제",
        cancelAction: { withAnimation(.easeInOut) { showAlert = false } },
        destructiveAction: {
          recordingDuration = 0
          withAnimation(.easeInOut) {
            showAlert = false
            musicVM.removeMusic()
            buttonState = .idle
          }
        })
        .zIndex(1000)
        .opacity(showAlert ? 1 : 0)

      if isPresented {
        PickerConfigViewControllerWrapper(isImagePickerClosed: $isImagePickerClosed)
      }
      if buttonState != .completed {
        viewModel.preview
          .frame(width: UIScreen.width, height: UIScreen.width * 16 / 9)
          .allowsHitTesting(false)
      } else {
        if let video = editorVM.currentVideo {
          EditablePlayerView(player: videoPlayer.videoPlayer)
            .overlay(alignment: .bottom) {
              Rectangle()
                .frame(height: UIScreen.getHeight(2))
                .foregroundStyle(.white)
                .overlay(alignment: .leading) {
                  Rectangle()
                    .frame(
                      width: UIScreen
                        .getWidth(UIScreen.width / video.totalDuration * videoPlayer.currentTime))
                    .foregroundStyle(Color.Blue_Default)
                }
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    if videoPlayer.isPlaying == false {
                      videoPlayer.playLoop(video)
                    }
                  }
                }
                .onChange(of: videoPlayer.isPlaying) { value in
                  if musicVM.musicInfo != nil {
                    switch value {
                    case true:
                      musicVM
                        .playAudio(startTime: 0)
                    case false:
                      musicVM.stopAudio()
                    }
                  }
                }
                .onChange(of: musicVM.isTrimmed) { value in
                  switch value {
                  case true:
                    videoPlayer.action(video)
                    musicVM.playAudio(startTime: 0)
                  case false:
                    videoPlayer.action(video)
                  }
                }
            }
            .onTapGesture {
              videoPlayer.playLoop(video)
            }
            .frame(width: UIScreen.width, height: UIScreen.width * 16 / 9)
            .padding(.bottom, 68)
        }
      }
      VStack {
        switch buttonState {
        case .idle:
          HStack(spacing: 24) {
            Button {
              bottomSheetPosition = .absolute(UIScreen.getHeight(514))
            } label: {
              HStack(spacing: 8) {
                Image(systemName: "clock")
                  .font(.system(size: 16))
                  .foregroundColor(.white)
                  .contentShape(Circle())
                if selectedSec.1 {
                  Text("\(selectedSec.0 == .sec3 ? 3 : 10)초")
                    .fontSystem(fontDesignSystem: .subtitle3_KO)
                    .foregroundColor(.white)
                }
              }
              .padding(.horizontal, selectedSec.1 ? 20 : 10)
              .frame(height: UIScreen.getHeight(36))
              .background {
                if selectedSec.1 {
                  Capsule()
                    .foregroundColor(Color.Primary_Default)
                } else {
                  glassMoriphicCircleView()
                    .overlay {
                      Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(LinearGradient.Border_Glass)
                    }
                }
              }
            }
            Button {
              if !isFront {
                toggleFlash()
              }
            } label: {
              Image(systemName: isFlashOn ? "bolt" : "bolt.slash.fill")
                .font(.system(size: 16))
                .padding(10)
                .foregroundColor(.white)
                .contentShape(Circle())
                .background {
                  if isFlashOn {
                    Circle()
                      .foregroundColor(Color.Primary_Default)
                  } else {
                    glassMoriphicCircleView()
                      .overlay {
                        Circle()
                          .stroke(lineWidth: 1)
                          .foregroundStyle(LinearGradient.Border_Glass)
                      }
                  }
                }
            }
            .frame(width: UIScreen.getWidth(36), height: UIScreen.getHeight(36))
            .allowsHitTesting(!isFront)
            .overlay {
              if isFront {
                Circle().frame(width: 36, height: 36).foregroundColor(.black.opacity(0.4))
              }
            }
          }
          .frame(height: 52)
          .hCenter()
          .overlay(alignment: .leading) {
            Button {
              tabbarModel.tabSelectionNoAnimation = tabbarModel.prevTabSelection ?? .main
              withAnimation {
                tabbarModel.tabSelection = tabbarModel.prevTabSelection ?? .main
              }
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding(16)
            }
          }
        case .recording:
          EmptyView()
        case .completed:
          HStack(spacing: 24) {
            Text("새 게시물")
              .fontSystem(fontDesignSystem: .subtitle1_KO)
              .foregroundStyle(Color.white)
          }
          .frame(height: 52)
          .hCenter()
          .overlay(alignment: .leading) {
            Button {
              showAlert = true
              if videoPlayer.isPlaying {
                if let video = editorVM.currentVideo {
                  videoPlayer.action(video)
                  musicVM.stopAudio()
                }
              }
//              tabbarModel.tabSelectionNoAnimation = .main
//              tabbarModel.tabSelection = .main
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding(16)
            }
          }
        }
        if buttonState == .completed {
          MusicInfo(musicVM: musicVM, showMusicTrimView: $showMusicTrimView) {
            if musicVM.musicInfo == nil {
              sheetPositions = [.absolute(UIScreen.getHeight(400)), .hidden, .relative(1)]
              bottomSheetPosition = .absolute(UIScreen.getHeight(400))
            }
          } onDelete: {
            withAnimation(.easeInOut) {
              musicVM.removeMusic()
              editorVM.removeAudio()
            }
          }
        }
        Spacer()
        HStack(spacing: 0) {
          // Album thumbnail + button
          Button {
            if isAlbumAuthorized {
              isImagePickerClosed.send(true)
            } else {
              showAlbumAccessView = true
            }
          } label: {
            roundRectangleShape(with: albumCover, size: 56)
              .vBottom()
          }
          .shadow(radius: 5)
          .contentShape(Rectangle())
          .onReceive(isImagePickerClosed) { value in
            isPresented = value
          }
          .opacity(buttonState == .idle ? 1 : 0)
          Spacer()
          // Shutter + button
          recordingButton(
            state: buttonState,
            timerText: timeStringFromTimeInterval(recordingDuration),
            progress: min(recordingDuration / Double(timerSec.1 ? Double(timerSec.0) : 14.0), 1.0))
          Spacer()
          // Position change + button
          Button(action: {
            guard let device = AVCaptureDevice.default(for: .video) else { return }

            if device.hasTorch {
              do {
                try device.lockForConfiguration()

                if device.torchMode == .on {
                  device.torchMode = .off
                  isFlashOn = false
                }
                device.unlockForConfiguration()
              } catch {
                print("Flash could not be used")
              }
            } else {
              print("Device does not have a Torch")
            }
            viewModel.aespaSession.position(to: isFront ? .back : .front)
            isFront.toggle()
          }) {
            VStack(spacing: 8) {
              ZStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                  .font(.system(size: 24))
                  .foregroundColor(.white)
                  .padding(16)
                  .background {
                    glassMoriphicCircleView()
                      .overlay {
                        Circle()
                          .stroke(lineWidth: 1)
                          .foregroundStyle(LinearGradient.Border_Glass)
                      }
                  }
              }
              Text("화면 전환")
                .foregroundColor(.white)
                .fontSystem(fontDesignSystem: .body2_KO)
            }
            .vBottom()
          }
          .contentShape(Circle())
          .opacity(buttonState == .idle ? 1 : 0)
        }
        .hCenter()
        .frame(height: UIScreen.getHeight(96))
        .padding(.horizontal, 42)
        .padding(.bottom, 24)
      }
      .frame(width: UIScreen.width, height: UIScreen.width * 16 / 9)
      .padding(.bottom, 74)
      .opacity(showPreparingView ? 0 : 1)
      if showPreparingView {
        Circle()
          .trim(from: 0, to: min(count / CGFloat(selectedSec.0 == .sec3 ? 3.0 : 10.0), 1.0))
          .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .square))
          .frame(width: 84)
          .rotationEffect(Angle(degrees: -90))
          .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
        Text("\(Int(count))")
          .fontSystem(fontDesignSystem: .largeTitle_Expanded)
          .foregroundColor(.white)
      }
    }
    .onDisappear {
      do {
        try Aespa.terminate()
        viewModel.preview = nil
      } catch { }
    }
    .fullScreenCover(isPresented: $showMusicTrimView) {
      MusicTrimView(
        musicVM: musicVM,
        editorVM: editorVM,
        videoPlayer: videoPlayer,
        showMusicTrimView: $showMusicTrimView)
    }
    .fullScreenCover(isPresented: $showAlbumAccessView, onDismiss: {
      if isAlbumAuthorized {
        guard let latestVideoAsset = fetchLatestVideo() else { return }
        guard let latestVideoThumbnail = generateThumbnail(for: latestVideoAsset) else { return }
        albumCover = Image(uiImage: latestVideoThumbnail)
      }
    }) {
      AlbumAccessView(isAlbumAuthorized: $isAlbumAuthorized, showAlbumAccessView: $showAlbumAccessView)
    }
    .navigationBarBackButtonHidden()
    .onAppear {
      getAlbumAuth()
      if isAlbumAuthorized {
        guard let latestVideoAsset = fetchLatestVideo() else { return }
        guard let latestVideoThumbnail = generateThumbnail(for: latestVideoAsset) else { return }
        albumCover = Image(uiImage: latestVideoThumbnail)
      }
      viewModel.aespaSession = Aespa.session(with: AespaOption(albumName: "Whistle"))
      Task {
        log("직접 가져오기")
      }
    }
    .onChange(of: scenePhase) { newValue in
      if newValue == .background {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
          do {
            try device.lockForConfiguration()

            if device.torchMode == .on {
              device.torchMode = .off
              isFlashOn = false
            }
            device.unlockForConfiguration()
          } catch {
            print("Flash could not be used")
          }
        } else {
          print("Device does not have a Torch")
        }
      }
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: sheetPositions)
    {
      switch buttonState {
      case .idle:
        timerSetView()
      case .recording:
        EmptyView()
      case .completed:
        MusicListView(
          musicVM: musicVM,
          editorVM: editorVM,
          videoPlayer: videoPlayer,
          bottomSheetPosition: $bottomSheetPosition,
          showMusicTrimView: $showMusicTrimView)
        {
          bottomSheetPosition = .relative(1)
        }
      }
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(width: UIScreen.width, height: .infinity, cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
  }
}

// MARK: - Extension for ViewBuilders

extension VideoContentView {
  @ViewBuilder
  func timerSetView() -> some View {
    VStack(spacing: 0) {
      HStack {
        Color.clear.frame(width: 28)
        Spacer()
        Text("타이머")
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.White)
        Spacer()
        Button {
          timerSec.1 = false
          bottomSheetPosition = .hidden
        } label: {
          Text("취소")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.White)
        }
      }
      .frame(height: 24)
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      Divider().frame(width: UIScreen.width)
      HStack {
        Text("카운트 다운")
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.LabelColor_Primary_Dark)
        Spacer()
        ZStack {
          glassToggle(width: 120, height: 34)
            .overlay {
              Capsule()
                .stroke(lineWidth: 1)
                .foregroundStyle(LinearGradient.Border_Glass)
                .frame(width: 120, height: 34)
                .overlay {
                  HStack(spacing: 0) {
                    if selectedSec.0 == .sec10 {
                      Spacer()
                    }
                    Capsule()
                      .frame(width: 58, height: 30)
                      .foregroundColor(Color.Dim_Default)
                      .overlay {
                        Capsule()
                          .stroke(lineWidth: 1)
                          .foregroundStyle(LinearGradient.Border_Glass)
                      }
                    if selectedSec.0 == .sec3 {
                      Spacer()
                    }
                  }
                  .frame(width: 116, height: 34)
                  .padding(.horizontal, 2)
                }
            }
          HStack(spacing: 0) {
            Spacer()
            Button {
              withAnimation {
                selectedSec.0 = .sec3
              }
            } label: {
              Text("3s")
                .fontSystem(fontDesignSystem: .subtitle3_KO)
                .foregroundColor(selectedSec.0 == .sec3 ? .White : Color.LabelColor_DisablePlaceholder)
                .frame(width: 58, height: 30)
            }
            .frame(width: 58, height: 30)
            Button {
              withAnimation {
                selectedSec.0 = .sec10
              }
            } label: {
              Text("10s")
                .fontSystem(fontDesignSystem: .subtitle3_KO)
                .foregroundColor(selectedSec.0 == .sec10 ? .White : Color.LabelColor_DisablePlaceholder)
                .frame(width: 58, height: 30)
            }
            .frame(width: 58, height: 30)
            Spacer()
          }
          .frame(width: 120, height: 34)
        }
        .frame(width: 120, height: 34)
      }
      .frame(width: UIScreen.width - 32, alignment: .leading)
      .padding(.horizontal, 16)
      .frame(height: 64)

      Text("영상 길이 설정")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary_Dark)
        .frame(height: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)

      // MARK: - 드래그

      HStack(alignment: .bottom) {
        RoundedRectangle(cornerRadius: 8)
          .foregroundColor(Color.Gray30_Dark)
          .frame(width: UIScreen.width - 32)
          .frame(height: 84)
          .reverseMask {
            RoundedRectangle(cornerRadius: 8)
              .frame(width: UIScreen.width - 48)
              .frame(height: 72)
          }
          .overlay {
            HStack(spacing: 0) {
              Spacer().frame(minWidth: 0)
              ForEach(0 ..< 14) { i in
                Capsule()
                  .frame(width: 6, height: i % 2 == 0 ? 22 : 42)
                  .foregroundColor(Color.Gray30_Dark)
                Spacer().frame(minWidth: 0)
              }
            }
            .padding(.horizontal, 6)
          }
          .overlay {
            HStack(spacing: 0) {
              RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(
                  LinearGradient(colors: [
                    Color.Primary_Darken,
                    Color.Secondary_Darken,
                  ], startPoint: .leading, endPoint: .trailing))
                .frame(width: CGFloat(defaultWidth + dragOffset), height: 84, alignment: .leading)
                .overlay {
                  HStack(spacing: 0) {
                    Spacer().frame(width: 8)
                    Spacer()
                    Spacer().frame(width: 34)
                      .overlay {
                        Capsule()
                          .foregroundColor(.white)
                          .frame(width: 4, height: 22)
                      }
                  }
                }
                .reverseMask {
                  HStack(spacing: 0) {
                    Spacer().frame(width: 8)
                    RoundedRectangle(cornerRadius: 8)
                      .frame(height: 72)
                      .frame(maxWidth: .infinity)
                    Spacer().frame(width: 34)
                  }
                }
                .gesture(
                  DragGesture()
                    .onChanged { value in
                      if
                        CGFloat(defaultWidth + value.translation.width) >
                        CGFloat(UIScreen.width - 32)
                      {
                        dragOffset = CGFloat((6 + barSpacing) * 7)
                      } else if defaultWidth + value.translation.width < 6 {
                        dragOffset = -CGFloat((6 + barSpacing) * 8)
                      } else {
                        dragOffset = value.translation.width
                      }
                    }
                    .onEnded { _ in
                      let dragValue = Int(dragOffset + defaultWidth)
                      let multiplier = 6 + barSpacing
                      switch dragValue {
                      case .min ..< 6 + Int(barSpacing):
                        withAnimation {
                          dragOffset = -8.0 * CGFloat(multiplier)
                          timerSec.0 = 0
                        }
                      case 6 - Int(barSpacing) ..< Int(multiplier) + Int(barSpacing):
                        withAnimation {
                          dragOffset = -7.0 * CGFloat(multiplier)
                          timerSec.0 = 1
                        }
                      case Int(multiplier) - Int(barSpacing) ..< Int(2 * multiplier) + Int(barSpacing):
                        withAnimation {
                          dragOffset = -6.0 * CGFloat(multiplier)
                          timerSec.0 = 2
                        }
                      case Int(2 * multiplier) - Int(barSpacing) ..< Int(3 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = -5.0 * CGFloat(multiplier)
                          timerSec.0 = 3
                        }
                      case Int(3 * multiplier) - Int(barSpacing) ..< Int(4 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = -4.0 * CGFloat(multiplier)
                          timerSec.0 = 4
                        }
                      case Int(4 * multiplier) - Int(barSpacing) ..< Int(5 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = -3.0 * CGFloat(multiplier)
                          timerSec.0 = 5
                        }
                      case Int(5 * multiplier) - Int(barSpacing) ..< Int(6 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = -2.0 * CGFloat(multiplier)
                          timerSec.0 = 6
                        }
                      case Int(6 * multiplier) - Int(barSpacing) ..< Int(7 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = -CGFloat(multiplier)
                          timerSec.0 = 7
                        }
                      case Int(7 * multiplier) - Int(barSpacing) ..< Int(8 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 0.0
                          timerSec.0 = 8
                        }
                      case Int(8 * multiplier) - Int(barSpacing) ..< Int(9 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = CGFloat(multiplier)
                          timerSec.0 = 9
                        }
                      case Int(9 * multiplier) - Int(barSpacing) ..< Int(10 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 2.0 * CGFloat(multiplier)
                          timerSec.0 = 10
                        }
                      case Int(10 * multiplier) - Int(barSpacing) ..< Int(11 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 3.0 * CGFloat(multiplier)
                          timerSec.0 = 11
                        }
                      case Int(11 * multiplier) - Int(barSpacing) ..< Int(12 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 4.0 * CGFloat(multiplier)
                          timerSec.0 = 12
                        }
                      case Int(12 * multiplier) - Int(barSpacing) ..< Int(13 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 5.0 * CGFloat(multiplier)
                          timerSec.0 = 13
                        }
                      case Int(13 * multiplier) - Int(barSpacing) ..< Int(14 * multiplier) +
                        Int(barSpacing):
                        withAnimation {
                          dragOffset = 6.0 * CGFloat(multiplier)
                          timerSec.0 = 14
                        }
                      case Int(14 * multiplier) - Int(barSpacing) ... Int.max:
                        withAnimation {
                          dragOffset = 7.0 * CGFloat(multiplier)
                          timerSec.0 = 15
                        }
                      default:
                        log("")
                      }
                    })
            }
            .frame(width: UIScreen.width - 32, alignment: .leading)
            HStack {
              Text("0s")
              Spacer()
              Text("15s")
            }
            .foregroundColor(Color.Gray30_Dark)
            .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            .offset(y: -53)
            HStack {
              Text("\(Int((defaultWidth + dragOffset - 6) / (barSpacing + 6)))s")
                .foregroundColor(Color.White)
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
                .frame(width: dragOffset + defaultWidth, alignment: .trailing)
            }
            .frame(width: UIScreen.width - 32, alignment: .leading)
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            .offset(y: -53)
          }
          .frame(height: 104)
      }
      .frame(width: UIScreen.width - 32, alignment: .leading)
      HStack {
        Text("끌어서 이 영상의 길이를 선택하세요. 타이머를 설정하면 녹화가 시작되기 전에 카운트 다운이 실행됩니다.")
          .fontSystem(fontDesignSystem: .caption_KO_Regular)
          .foregroundColor(Color.LabelColor_Primary_Dark)
      }
      .padding([.horizontal, .bottom], 16)
      .frame(height: 60)
      Button {
        withAnimation {
          timerSec.1 = true
          selectedSec.1 = true
          bottomSheetPosition = .hidden
        }
      } label: {
        Text("타이머 설정")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .frame(maxWidth: .infinity)
          .background {
            Capsule()
              .frame(height: 48)
              .frame(maxWidth: .infinity)
              .foregroundColor(Color.Blue_Default)
          }
      }
      .frame(height: 48)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 8)
      .padding(.bottom, 8)
      Button("타이머 해제") {
        withAnimation {
          timerSec.0 = 8
          timerSec.1 = false
          selectedSec.0 = .sec3
          selectedSec.1 = false
          bottomSheetPosition = .hidden
        }
      }
      .fontSystem(fontDesignSystem: .subtitle2_KO)
      .foregroundColor(Color.Info)
      .frame(height: 48)
      .frame(maxWidth: .infinity)
      Spacer()
    }
  }

  @ViewBuilder
  func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
    VStack(spacing: 8) {
      image
        .resizable()
        .scaledToFill()
        .frame(width: size, height: size, alignment: .center)
        .clipped()
        .cornerRadius(6)
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(Color.LabelColor_Primary_Dark, lineWidth: 1))
      Text("앨범")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Primary_Dark)
    }
  }

  @ViewBuilder
  func glassToggle(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      Capsule()
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 32
      }
      .clipShape(Capsule())
    }
    .frame(width: width, height: height)
  }
}

// MARK: - AssetType

enum AssetType {
  case video
  case photo
}

// MARK: - VideoContentView_Previews

struct VideoContentView_Previews: PreviewProvider {
  static var previews: some View {
    VideoContentView()
  }
}

// MARK: - SelectedSecond

enum SelectedSecond: Int {
  case sec3 = -1
  case sec10 = 1
}

// MARK: - Extension for Timer Functions

extension VideoContentView {
  func toggleFlash() {
    guard let device = AVCaptureDevice.default(for: .video) else { return }

    if device.hasTorch {
      do {
        try device.lockForConfiguration()

        if device.torchMode == .on {
          device.torchMode = .off
          isFlashOn = false
        } else {
          try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
          isFlashOn = true
        }
        device.unlockForConfiguration()
      } catch {
        print("Flash could not be used")
      }
    } else {
      print("Device does not have a Torch")
    }
  }

  private func startPreparingTimer() {
    count = CGFloat(selectedSec.0 == .sec3 ? 3 : 10)
    showPreparingView = true
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      if count == 0 {
        showPreparingView = false
        selectedSec.0 = .sec3
        selectedSec.1 = false
        buttonState = .recording
        viewModel.aespaSession.startRecording()
        startRecordingTimer()
        isRecording = true
      } else {
        withAnimation(.linear(duration: 1.0)) {
          count -= 1
        }
      }
    }
  }

  private func startRecordingTimer() {
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      if recordingDuration >= Double(timerSec.1 ? Double(timerSec.0) : 14.0) {
        buttonState = .completed
        stopRecordingTimer()
        isRecording = false
        viewModel.aespaSession.stopRecording { result in
          switch result {
          case .success(let videoURL):
            setVideo(videoURL)
          case .failure(let error):
            print("Error: \(error)")
          }
        }
      } else {
        recordingDuration += 1
      }
    }
  }

  private func stopRecordingTimer() {
    recordingTimer?.invalidate()
    recordingTimer = nil
    timerSec.0 = 8
    timerSec.1 = false
  }

  // 시간을 TimeInterval에서 "00:00" 형식의 문자열로 변환
  private func timeStringFromTimeInterval(_ interval: TimeInterval) -> String {
    let minutes = Int(interval) / 60
    let seconds = Int(interval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

// MARK: - CameraButtonState

enum CameraButtonState {
  case idle
  case recording
  case completed
}

// MARK: - Extension for Recording Button ViewBuilder

extension VideoContentView {
  @ViewBuilder
  func recordingButton(state: CameraButtonState, timerText: String, progress: Double) -> some View {
    ZStack {
      switch state {
      case .idle:
        ZStack {
          Circle()
            .stroke(lineWidth: 4)
            .foregroundColor(.White)
            .frame(width: 84, height: 84, alignment: .center)
          Circle()
            .fill(LinearGradient(
              gradient: Gradient(colors: [Color.Primary_Default, Color.Secondary_Default]),
              startPoint: .trailing,
              endPoint: .leading))
            .frame(width: 72, height: 72, alignment: .center)
        }
        .onTapGesture {
          if timerSec.1 {
            startPreparingTimer()
          } else {
            withAnimation {
              buttonState = .recording
            }
            viewModel.aespaSession.startRecording()
            startRecordingTimer()
            isRecording = true
          }
        }
      case .recording:
        VStack {
          Text(timerText) // 시간을 표시할 텍스트
            .font(.custom("SFProText-Semibold", size: 16))
            .foregroundColor(.Gray10)
          ZStack {
            Circle()
              .foregroundColor(.Dim_Thick)
              .frame(width: 114, height: 114, alignment: .center)
            Circle()
              .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
              .stroke(lineWidth: 5)
              .foregroundColor(.Primary_Default)
              .frame(width: 109, height: 109, alignment: .center)
              .rotationEffect(Angle(degrees: -90))
              .animation(.linear(duration: 1.0))
            Rectangle()
              .foregroundColor(.White)
              .cornerRadius(8)
              .frame(width: 36, height: 36, alignment: .center)
          }
        }
        .padding(.bottom, 40)
        .onAppear {
          withAnimation(.linear(duration: 0.5)) {
            animatedProgress = progress
          }
        }
        .onChange(of: progress) { newValue in
          print("progress:", newValue)
          withAnimation(.linear(duration: 0.5)) {
            animatedProgress = newValue
          }
        }
        .onTapGesture {
          buttonState = .completed
          viewModel.aespaSession.stopRecording { result in
            switch result {
            case .success(let videoURL):
              setVideo(videoURL)
            case .failure(let error):
              print("Error: \(error)")
            }
          }
          stopRecordingTimer()
          isRecording = false
        }
      case .completed:
        Button {
          disableUploadButton = true
          if musicVM.isTrimmed {
            editorVM.currentVideo?.setVolume(0)
          }
          Task {
            UploadProgressViewModel.shared.uploadStarted()
            tabbarModel.tabSelectionNoAnimation = .main
            tabbarModel.tabSelection = .main
          }
          Task {
            if let video = editorVM.currentVideo {
              let thumbnail = video.getFirstThumbnail()
              if let thumbnail {
                UploadProgressViewModel.shared.thumbnail = Image(uiImage: thumbnail)
              }
              let exporterVM = ExporterViewModel(video: video)
              await exporterVM.action(.save, start: video.rangeDuration.lowerBound)
              apiViewModel.uploadPost(
                video: exporterVM.videoData,
                thumbnail: thumbnail?.jpegData(compressionQuality: 0.5)! ?? Data(),
                caption: "",
                musicID: musicVM.musicInfo?.musicID ?? 0,
                videoLength: video.totalDuration,
                hashtags: [""])
            }
          }

        } label: {
          Circle()
            .stroke(lineWidth: 4)
            .foregroundColor(.White)
            .frame(width: 84, height: 84, alignment: .center)
            .overlay {
              Circle()
                .foregroundColor(.Primary_Default)
                .frame(width: 72, height: 72, alignment: .center)
              Image(systemName: "checkmark")
                .font(.custom("SFCompactText-Regular", size: 44))
                .foregroundColor(.White)
            }
        }
        .disabled(disableUploadButton)
      }
    }
  }
}

// MARK: - Extension for Video Functions

extension VideoContentView {
  private func setVideo(_ url: URL) {
    selectedVideoURL = url
    if let selectedVideoURL {
      editorVM.setNewVideo(selectedVideoURL)
      videoPlayer.loadState = .loaded(selectedVideoURL)
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

extension VideoContentView {
  func getAlbumAuth() {
    switch authorizationStatus {
    case .notDetermined:
      log("notDetermined")
    case .restricted:
      log("restricted")
    case .denied:
      log("restricted")
    case .authorized:
      isAlbumAuthorized = true
    case .limited:
      isAlbumAuthorized = true
    @unknown default:
      log("unknown default")
    }
  }
}

extension VideoContentView {

  func fetchLatestVideo() -> PHAsset? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
    return fetchResult.firstObject
  }

  func generateThumbnail(for asset: PHAsset) -> UIImage? {
    let imageManager = PHCachingImageManager()
    let options = PHImageRequestOptions()
    options.isSynchronous = true

    var thumbnail: UIImage?
    imageManager.requestImage(
      for: asset,
      targetSize: CGSize(width: 100, height: 100),
      contentMode: .aspectFill,
      options: options)
    { result, _ in
      thumbnail = result
    }
    return thumbnail
  }

}
