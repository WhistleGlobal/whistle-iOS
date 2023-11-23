//
//  VideoCaptureView.swift
//  TestCamera
//
//  Created by ChoiYujin on 10/11/23.
//

import _AuthenticationServices_SwiftUI
import Aespa
import AVFoundation
import BottomSheet
import Combine
import Photos
import ReverseMask
import SwiftUI

// MARK: - VideoCaptureView

struct VideoCaptureView: View {
  // MARK: - Objects

  @AppStorage("isAccess") var isAccess = false
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  @StateObject var editorVM = VideoEditorViewModel()
  @StateObject var videoPlayer = VideoPlayerManager()
  @StateObject var musicVM = MusicViewModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @StateObject var tabbarModel = TabbarModel.shared
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var guestUploadModel = GuestUploadModel.shared
  @ObservedObject var viewModel = VideoCaptureViewModel()

  // MARK: - Datas

  @State var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State var isImagePickerClosed = PassthroughSubject<Bool, Never>()
  @State var buttonState: VideoCaptureState = .idle
  @State var captureMode: AssetType = .video
  @State var selectedSec = (SelectedSecond.sec3, false)
  @State var recordingDuration: TimeInterval = 0
  @State var recordingTimer: Timer?
  @State var selectedVideoURL: URL?
  @State var project: ProjectEntity?
  @State var animatedProgress = 0.0
  @State var count: CGFloat = 0
  @State var dragOffset: CGFloat = 0
  @State var accumulatedOffset: CGFloat = 0
  @State var sheetPositions: [BottomSheetPosition] = [.hidden, .absolute(514)]
  @State var musicBottomSheetPosition: BottomSheetPosition = .hidden
  @State var uploadBottomSheetPosition: BottomSheetPosition = .hidden
  @State var albumCover = Image("noVideo")
  @State var thumbnail: Image?
  // MARK: - Bools

  @State var isAlbumAuthorized = false
  @State var showAlbumAccessView = false
  @State var disableUploadButton = false
  @State var isRecording = false
  @State var isFront = false
  @State var isFlashOn = false
  @State var showSetting = false
  @State var showGallery = false
  @State var showPreparingView = false
  @State var isPresented = false
  @State var timerSec = (15, false)
  /// 음악 편집기 띄우기용
  @State var showMusicTrimView = false
  @State var currentZoomScale: CGFloat = 1.0
  // 방침
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false

  // MARK: - Computed

  var barSpacing: CGFloat {
    CGFloat((UIScreen.width - 32 - 12 - (14 * 6)) / 15)
  }

  var defaultWidth: CGFloat {
    CGFloat(6 + (6 + barSpacing) * 15)
  }

  var zoomFormattedString: String {
    let formattedString = String(format: "%.1fx", currentZoomScale)
    return formattedString.hasSuffix(".0x") ? String(format: "%.0fx", currentZoomScale) : formattedString
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.black.ignoresSafeArea()
        NavigationLink(destination: PrivacyPolicyView(), isActive: $showPrivacyPolicy) {
          EmptyView()
        }
        NavigationLink(destination: TermsOfServiceView(), isActive: $showTermsOfService) {
          EmptyView()
        }
        if let video = editorVM.currentVideo {
          NavigationLink(
            destination:
            DescriptionEditorView(
              video: video,
              thumbnail: thumbnail,
              editorVM: editorVM,
              videoPlayer: videoPlayer,
              musicVM: musicVM,
              isInitial: .constant(false)),
            isActive: $guestUploadModel.goDescriptionTagView)
          {
            EmptyView()
          }
        }
        if musicBottomSheetPosition == .absolute(UIScreen.getHeight(514)) {
          DimsThick().zIndex(1000)
        }
        if isPresented {
          PickerConfigViewControllerWrapper(isImagePickerClosed: $isImagePickerClosed)
        }
        if buttonState != .completed || editorVM.currentVideo == nil {
          viewModel.preview.ignoresSafeArea()
        } else {
          if let video = editorVM.currentVideo {
            recordedVideoPreview(video: video)
              .ignoresSafeArea()
          } else {
            Image("BlurredDefaultBG")
          }
        }
        // preview 위의 버튼들
        VStack {
          // 상단 버튼
          toolBar
            .padding(.top, 48)
          // 음악 추가 버튼
          if buttonState == .completed {
            MusicInfo(musicVM: musicVM, showMusicTrimView: $showMusicTrimView) {
              if isAccess {
                if musicVM.musicInfo == nil {
                  sheetPositions = [.absolute(UIScreen.getHeight(400)), .hidden, .relative(1)]
                  musicBottomSheetPosition = .absolute(UIScreen.getHeight(400))
                }
              } else {
                guestUploadModel.isMusicEdit = true
                uploadBottomSheetPosition = .dynamic
              }
            } onDelete: {
              withAnimation(.easeInOut) {
                musicVM.removeMusic()
                editorVM.removeAudio()
              }
            }
          }
          Spacer()
          // 하단 버튼
          recordingButton(
            timerText: timeStringFromTimeInterval(recordingDuration),
            progress: min(recordingDuration / Double(timerSec.1 ? Double(timerSec.0) : 15.0), 1.0))
        }
        .frame(width: UIScreen.width, height: UIScreen.height)
        .ignoresSafeArea()
        .opacity(showPreparingView ? 0 : 1)
        if showPreparingView {
          Circle()
            .trim(from: 0, to: min(count / CGFloat(selectedSec.0 == .sec3 ? 3.0 : 10.0), 1.0))
            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .square))
            .frame(width: 84)
            .rotationEffect(Angle(degrees: -90))
            .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
          Text("\(Int(count + 0.9))")
            .fontSystem(fontDesignSystem: .largeTitle_Expanded)
            .foregroundColor(.white)
        }
      }
      .overlay {
        if disableUploadButton {
          DimsThin()
          LottieProgress()
        }
      }
      .frame(width: UIScreen.width, height: UIScreen.height)
      .ignoresSafeArea(.keyboard)
      .navigationBarBackButtonHidden()
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
      .overlay {
        if alertViewModel.onFullScreenCover {
          AlertPopup()
        }
      }
      .onDisappear {
        do {
          try Aespa.terminate()
          viewModel.preview = nil
          guestUploadModel.isNotAccessRecord = false
        } catch { }
        if videoPlayer.isPlaying {
          if let video = editorVM.currentVideo {
            videoPlayer.action(video)
          }
        }
      }
      .onAppear {
        guestUploadModel.isNotAccessRecord = !isAccess
        alertViewModel.onFullScreenCover = true
        getAlbumAuth()
        if isAlbumAuthorized {
          guard let latestVideoAsset = fetchLatestVideo() else { return }
          guard let latestVideoThumbnail = generateThumbnail(for: latestVideoAsset) else { return }
          albumCover = Image(uiImage: latestVideoThumbnail)
        }
        viewModel.aespaSession = Aespa.session(with: AespaOption(albumName: "Whistle"))
        viewModel.preview = viewModel.aespaSession.interactivePreview()
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
              WhistleLogger.logger.debug("Flash could not be used")
            }
          } else {
            WhistleLogger.logger.debug("Device does not have a Torch")
          }
          if guestUploadModel.istempAccess {
            isAccess = true
            tabbarModel.showTabbar()
          }
        }
      }
      .onChange(of: guestUploadModel.istempAccess) { newValue in
        if newValue {
          uploadBottomSheetPosition = .hidden
          if guestUploadModel.isMusicEdit {
            musicBottomSheetPosition = .relative(1)
          }
          if guestUploadModel.isPhotoLibraryAccess {
            isImagePickerClosed.send(true)
          }
        }
      }
      .bottomSheet(
        bottomSheetPosition: $musicBottomSheetPosition,
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
            bottomSheetPosition: $musicBottomSheetPosition,
            showMusicTrimView: $showMusicTrimView)
        }
      }
      .enableSwipeToDismiss(true)
      .enableTapToDismiss(true)
      .enableContentDrag(true)
      .enableAppleScrollBehavior(false)
      .dragIndicatorColor(Color.Border_Default_Dark)
      .customBackground(
        glassMorphicView(cornerRadius: 24)
          .overlay {
            RoundedRectangle(cornerRadius: 24)
              .stroke(lineWidth: 1)
              .foregroundStyle(
                LinearGradient.Border_Glass)
          })
      .bottomSheet(
        bottomSheetPosition: $uploadBottomSheetPosition,
        switchablePositions: [.hidden, .dynamic])
      {
        loginSheet()
      }
      .enableSwipeToDismiss(true)
      .enableTapToDismiss(true)
      .enableContentDrag(true)
      .enableAppleScrollBehavior(false)
      .dragIndicatorColor(Color.Border_Default_Dark)
      .customBackground(
        glassMorphicView(cornerRadius: 24)
          .overlay {
            RoundedRectangle(cornerRadius: 24)
              .stroke(lineWidth: 1)
              .foregroundStyle(
                LinearGradient.Border_Glass)
          })
      .onDismiss {
        uploadBottomSheetPosition = .hidden
        tabbarModel.showTabbar()
      }
      .onChange(of: uploadBottomSheetPosition) { newValue in
        if newValue == .hidden {
          tabbarModel.showTabbar()
        } else {
          tabbarModel.hideTabbar()
        }
      }
    }
  }
}

// MARK: - AssetType

enum AssetType {
  case video
  case photo
}

// MARK: - SelectedSecond

enum SelectedSecond: Int {
  case sec3 = -1
  case sec10 = 1
}
