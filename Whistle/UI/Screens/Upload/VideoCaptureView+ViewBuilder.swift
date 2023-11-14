//
//  VideoCaptureView+ViewBuilder.swift
//  Whistle
//
//  Created by 박상원 on 11/10/23.
//

import _AuthenticationServices_SwiftUI
import Aespa
import AVFoundation
import Combine
import SwiftUI

extension VideoCaptureView {
  @ViewBuilder
  func loginSheet() -> some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Button {
          tabbarModel.tabbarOpacity = 1.0
          uploadBottomSheetPosition = .hidden
        } label: {
          Text(CommonWords().cancel)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
        }
      }
      .frame(height: 52)
      .padding(.bottom, 36)
      Group {
        Text("Whistle")
          .font(.system(size: 24, weight: .semibold)) +
          Text("에 로그인")
          .font(.custom("AppleSDGothicNeo-SemiBold", size: 24))
      }
      .fontWidth(.expanded)
      .lineSpacing(8)
      .padding(.vertical, 4)
      .padding(.bottom, 12)
      .foregroundColor(.LabelColor_Primary_Dark)
      Text("더 많은 스포츠 콘텐츠를 즐겨보세요")
        .fontSystem(fontDesignSystem: .body1)
        .foregroundColor(.LabelColor_Secondary_Dark)
      Spacer()
      Button {
        handleSignInButton()
      } label: {
        Capsule()
          .foregroundColor(.white)
          .frame(maxWidth: 360, maxHeight: 48)
          .overlay {
            HStack(alignment: .center) {
              Image("GoogleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
              Spacer()
              Text("Google로 계속하기")
                .font(.custom("Roboto-Medium", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.54))
              Spacer()
              Color.clear
                .frame(width: 18, height: 18)
            }
            .padding(.horizontal, 24)
          }
          .padding(.bottom, 16)
      }

      SignInWithAppleButton(
        onRequest: appleSignInViewModel.configureRequest,
        onCompletion: appleSignInViewModel.handleResult)
        .frame(maxWidth: 360, maxHeight: 48)
        .cornerRadius(48)
        .overlay {
          Capsule()
            .foregroundColor(.black)
            .frame(maxWidth: 360, maxHeight: 48)
            .overlay {
              HStack(alignment: .center) {
                Image(systemName: "apple.logo")
                  .resizable()
                  .scaledToFit()
                  .foregroundColor(.white)
                  .frame(width: 18, height: 18)
                Spacer()
                Text("Apple로 계속하기")
                  .font(.system(size: 16))
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                Spacer()
                Color.clear
                  .frame(width: 18, height: 18)
              }
              .padding(.horizontal, 24)
            }
            .allowsHitTesting(false)
        }
        .padding(.bottom, 24)
      Text("가입을 진행할 경우, 아래의 정책에 대해 동의한 것으로 간주합니다.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .foregroundColor(.LabelColor_Primary_Dark)
      HStack(spacing: 16) {
        Button {
          showTermsOfService = true
        } label: {
          Text("이용약관")
            .font(.system(size: 12, weight: .semibold))
            .underline(true, color: .LabelColor_Primary_Dark)
        }
        Button {
          showPrivacyPolicy = true
        } label: {
          Text("개인정보처리방침")
            .font(.system(size: 12, weight: .semibold))
            .underline(true, color: .LabelColor_Primary_Dark)
        }
      }
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.bottom, 64)
    }
    .frame(height: UIScreen.height * 0.7)
  }

  @ViewBuilder
  func timerSetView() -> some View {
    VStack(spacing: 0) {
      HStack {
        Color.clear.frame(width: 28)
        Spacer()
        Text(CommonWords().timer)
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.white)
        Spacer()
        Button {
          timerSec.1 = false
          musicBottomSheetPosition = .hidden
        } label: {
          Text(CommonWords().cancel)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.white)
        }
      }
      .frame(height: 24)
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      Divider().frame(width: UIScreen.width)
      HStack {
        Text(VideoCaptureWords().countdown)
          .fontSystem(fontDesignSystem: .subtitle1)
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
                .fontSystem(fontDesignSystem: .subtitle3)
                .foregroundColor(selectedSec.0 == .sec3 ? .white : Color.LabelColor_DisablePlaceholder)
                .frame(width: 58, height: 30)
            }
            .frame(width: 58, height: 30)
            Button {
              withAnimation {
                selectedSec.0 = .sec10
              }
            } label: {
              Text("10s")
                .fontSystem(fontDesignSystem: .subtitle3)
                .foregroundColor(selectedSec.0 == .sec10 ? .white : Color.LabelColor_DisablePlaceholder)
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

      Text(VideoCaptureWords().setVideoLength)
        .fontSystem(fontDesignSystem: .subtitle2)
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
                    Color.Primary_Default,
                    Color.Secondary_Default,
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
                      WhistleLogger.logger.debug("length \((defaultWidth + dragOffset - 6) / (barSpacing + 6))")
                      dragOffset = max(-CGFloat((6 + barSpacing) * 14), min(0, accumulatedOffset + value.translation.width))
                    }
                    .onEnded { _ in
                      accumulatedOffset = dragOffset
                      let dragValue = Int(dragOffset + defaultWidth)
                      let multiplier = 6 + barSpacing
                      withAnimation {
                        switch dragValue {
                        case .min ..< 6 + Int(barSpacing):
                          dragOffset = -14.0 * CGFloat(multiplier)
                          timerSec.0 = 1

                        case 6 - Int(barSpacing) ..< Int(multiplier) + Int(barSpacing):
                          dragOffset = -14.0 * CGFloat(multiplier)
                          timerSec.0 = 1

                        case Int(multiplier) - Int(barSpacing) ..< Int(2 * multiplier) + Int(barSpacing):
                          dragOffset = -13.0 * CGFloat(multiplier)
                          timerSec.0 = 2

                        case Int(2 * multiplier) - Int(barSpacing) ..< Int(3 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -12.0 * CGFloat(multiplier)
                          timerSec.0 = 3

                        case Int(3 * multiplier) - Int(barSpacing) ..< Int(4 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -11.0 * CGFloat(multiplier)
                          timerSec.0 = 4

                        case Int(4 * multiplier) - Int(barSpacing) ..< Int(5 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -10.0 * CGFloat(multiplier)
                          timerSec.0 = 5

                        case Int(5 * multiplier) - Int(barSpacing) ..< Int(6 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -9.0 * CGFloat(multiplier)
                          timerSec.0 = 6

                        case Int(6 * multiplier) - Int(barSpacing) ..< Int(7 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -8.0 * CGFloat(multiplier)
                          timerSec.0 = 7

                        case Int(7 * multiplier) - Int(barSpacing) ..< Int(8 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -7.0 * CGFloat(multiplier)
                          timerSec.0 = 8

                        case Int(8 * multiplier) - Int(barSpacing) ..< Int(9 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -6.0 * CGFloat(multiplier)
                          timerSec.0 = 9

                        case Int(9 * multiplier) - Int(barSpacing) ..< Int(10 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -5.0 * CGFloat(multiplier)
                          timerSec.0 = 10

                        case Int(10 * multiplier) - Int(barSpacing) ..< Int(11 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -4.0 * CGFloat(multiplier)
                          timerSec.0 = 11

                        case Int(11 * multiplier) - Int(barSpacing) ..< Int(12 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -3.0 * CGFloat(multiplier)
                          timerSec.0 = 12

                        case Int(12 * multiplier) - Int(barSpacing) ..< Int(13 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -2.0 * CGFloat(multiplier)
                          timerSec.0 = 13

                        case Int(13 * multiplier) - Int(barSpacing) ..< Int(14 * multiplier) +
                          Int(barSpacing):
                          dragOffset = -1.0 * CGFloat(multiplier)
                          timerSec.0 = 14

                        case Int(14 * multiplier) - Int(barSpacing) ... Int.max:
                          dragOffset = 0
                          timerSec.0 = 15

                        default:
                          break
                        }
                      }
                      WhistleLogger.logger.debug("length: \((defaultWidth + dragOffset - 6) / (barSpacing + 6))")

                    })
            }
            .frame(width: UIScreen.width - 32, alignment: .leading)
            HStack {
              Text("0s")
              Spacer()
              Text("15s")
            }
            .foregroundColor(Color.Gray30_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .offset(y: -53)
            HStack {
              Text("\(Int((defaultWidth + dragOffset - 6) / (barSpacing + 6)))s")
                .foregroundColor(Color.white)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
                .frame(width: dragOffset + defaultWidth, alignment: .trailing)
            }
            .frame(width: UIScreen.width - 32, alignment: .leading)
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .offset(y: -53)
          }
          .frame(height: 104)
      }
      .frame(width: UIScreen.width - 32, alignment: .leading)
      HStack {
        Text(VideoCaptureWords().timerComment)
          .fontSystem(fontDesignSystem: .caption_Regular)
          .foregroundColor(Color.LabelColor_Primary_Dark)
      }
      .padding([.horizontal, .bottom], 16)
      .frame(height: 60)
      Button {
        withAnimation {
          timerSec.1 = true
          selectedSec.1 = true
          musicBottomSheetPosition = .hidden
        }
      } label: {
        Text(VideoCaptureWords().setTimer)
          .fontSystem(fontDesignSystem: .subtitle2)
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
      Button(VideoCaptureWords().disableTimer) {
        withAnimation {
          timerSec.0 = 15
          timerSec.1 = false
          selectedSec.0 = .sec3
          selectedSec.1 = false
          musicBottomSheetPosition = .hidden
        }
      }
      .fontSystem(fontDesignSystem: .subtitle2)
      .foregroundColor(Color.Info)
      .frame(height: 48)
      .frame(maxWidth: .infinity)
      Spacer()
    }
  }

  @ViewBuilder
  func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
    image
      .resizable()
      .scaledToFill()
      .frame(width: size, height: size, alignment: .center)
      .clipped()
      .cornerRadius(6)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Color.LabelColor_Primary_Dark, lineWidth: 1))
  }

  @ViewBuilder
  func glassToggle(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      Capsule()
        .fill(Color.black.opacity(0.3))
      CustomBlurEffect(effect: .systemUltraThinMaterialLight) { view in
        view.saturationAmount = 2.2
        view.gaussianBlurRadius = 32
      }
      .clipShape(Capsule())
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  var toolBar: some View {
    switch buttonState {
    case .idle:
      HStack(spacing: 24) {
        Button {
          musicBottomSheetPosition = .absolute(UIScreen.getHeight(514))
        } label: {
          HStack(spacing: 0) {
            Image(systemName: "clock")
              .font(.system(size: 14))
              .foregroundColor(.white)
            if selectedSec.1 {
              Text("\(selectedSec.0 == .sec3 ? 3 : 10)초")
                .fontSystem(fontDesignSystem: .subtitle3)
                .foregroundColor(.white)
            }
          }
          .frame(height: 36)
          .padding(.horizontal, 10)
          .background {
            if selectedSec.1 {
              Capsule()
                .foregroundColor(Color.Primary_Default)
            } else {
              glassMoriphicCircleView()
              Circle()
                .stroke(lineWidth: 1)
                .foregroundStyle(LinearGradient.Border_Glass)
            }
          }
        }
        Button {
          currentZoomScale = 1.0
          viewModel.preview?.resetZoom()
        } label: {
          Text(zoomFormattedString)
            .font(.system(size: 14, weight: .semibold))
            .lineSpacing(6)
            .padding(.vertical, 3)
            .frame(width: UIScreen.getWidth(36), height: UIScreen.getHeight(36))
            .foregroundColor(.white)
            .contentShape(Circle())
            .background {
              glassMoriphicCircleView()
                .overlay {
                  Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)
                }
            }
        }
        .onReceive(ZoomFactorCombineViewModel.shared.zoomSubject) { value in
          currentZoomScale = value
        }
        Button {
          if !isFront {
            toggleFlash()
          }
        } label: {
          Image(systemName: isFlashOn ? "bolt" : "bolt.slash.fill")
            .frame(width: UIScreen.getWidth(36), height: UIScreen.getHeight(36))
            .font(.system(size: 14))
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
        .allowsHitTesting(!isFront)
        .overlay {
          if isFront {
            Circle().frame(width: 36, height: 36).foregroundColor(.black.opacity(0.4))
          }
        }
      }
      .hCenter()
      .overlay(alignment: .leading) {
        Button {
          currentZoomScale = 1.0
          viewModel.preview?.resetZoom()
          if guestUploadModel.istempAccess {
            isAccess = true
          }
          tabbarModel.showVideoCaptureView = false
          alertViewModel.onFullScreenCover = false
          if let video = editorVM.currentVideo {
            if videoPlayer.isPlaying {
              videoPlayer.action(video)
            }
          }
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(16)
        }
      }
      .padding(.top, 12)
    case .recording:
      EmptyView()
    case .completed:
      HStack(spacing: 24) {
        Text(ContentWords().newContent)
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundStyle(Color.white)
      }
      .hCenter()
      .overlay(alignment: .leading) {
        Button {
          alertViewModel.linearAlert(
            isImmediateDismiss: true,
            isRed: true,
            title: AlertTitles().discardMedia,
            content: AlertContents().discardMedia,
            cancelText: AlertButtons().continueEditing,
            destructiveText: AlertButtons().discardMedia)
          {
            recordingDuration = 0
            withAnimation(.easeInOut) {
              musicVM.removeMusic()
              buttonState = .idle
            }
            editorVM.currentVideo = nil
            editorVM.reset()
            videoPlayer.reset()
            selectedVideoURL = nil
          }
          if videoPlayer.isPlaying {
            if let video = editorVM.currentVideo {
              videoPlayer.action(video)
              musicVM.stopAudio()
            }
          }
        } label: {
          Image(systemName: "chevron.backward")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(16)
        }
      }
      .padding(.top, 12)
    }
  }

  @ViewBuilder
  func recordedVideoPreview(video: EditableVideo) -> some View {
    EditablePlayer(player: videoPlayer.videoPlayer, isFullScreen: true)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          videoPlayer.playLoop(video)
        }
      }
      .onTapGesture {
        videoPlayer.playLoop(video)
      }
      .onChange(of: videoPlayer.isPlaying) { value in
        switch value {
        case true:
          if
            let startTime = musicVM.startTime,
            let duration = editorVM.currentVideo?.rangeDuration
          {
            let minTime = duration.lowerBound
            let videoCurrentTime = videoPlayer.currentTime
            let timeOffset = duration.upperBound <= videoCurrentTime ? 0 : videoCurrentTime - minTime
            musicVM
              .playTrimmedAudio(startTime: timeOffset)
          }
        case false:
          musicVM.stopAudio()
        }
      }
  }

  @ViewBuilder
  func recordingButton(timerText: String, progress: Double) -> some View {
    ZStack {
      if buttonState == .idle {
        HStack {
          Button {
            if isAlbumAuthorized {
              if isAccess {
                isImagePickerClosed.send(true)
              } else {
                guestUploadModel.isPhotoLibraryAccess = true
                if guestUploadModel.istempAccess {
                  isImagePickerClosed.send(true)
                } else {
                  uploadBottomSheetPosition = .dynamic
                }
              }
            } else {
              showAlbumAccessView = true
            }
          } label: {
            roundRectangleShape(with: albumCover, size: 56)
              .overlay(alignment: .bottom) {
                Text(CommonWords().album)
                  .fontSystem(fontDesignSystem: .body2)
                  .foregroundColor(.LabelColor_Primary_Dark)
                  .offset(y: 30)
              }
          }
          .frame(width: 80, height: 80)
          .contentShape(Rectangle())
          .onReceive(isImagePickerClosed) { value in
            isPresented = value
          }
          Spacer()
          Circle()
            .stroke(lineWidth: 4)
            .foregroundColor(.white)
            .overlay(alignment: .top) {
              Text("\(timerSec.0)초")
                .fontSystem(fontDesignSystem: .subtitle3)
                .foregroundColor(.Gray60_Dark)
                .padding(.vertical, 2)
                .padding(.horizontal, 16)
                .background {
                  Capsule()
                    .foregroundColor(.white)
                }
                .offset(y: -55)
            }
            .frame(width: 80, height: 80)
          Spacer()
          Button {
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
            viewModel.aespaSession.position(to: isFront ? .back : .front)
            isFront.toggle()
          } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 20))
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
              .overlay(alignment: .bottom) {
                Text(VideoCaptureWords().cameraSwitch)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .body2)
                  .offset(y: 30)
              }
          }
          .frame(width: 80, height: 80)
          .contentShape(Circle())
        }
      }
      if buttonState != .completed {
        RoundedRectangle(cornerRadius: buttonState.size.buttonRadius)
          .fill(buttonState.buttonColor)
          .frame(width: buttonState.size.buttonSize, height: buttonState.size.buttonSize)
          .background {
            Circle()
              .fill(.black)
              .opacity(0.3)
              .frame(width: buttonState.size.dimSize, height: buttonState.size.dimSize)
            if buttonState == .recording {
              Text(timerText)
                .font(.custom("SFProText-Semibold", size: 16))
                .foregroundColor(.Gray10)
                .offset(y: -80)
              Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(lineWidth: 5)
                .foregroundColor(.Primary_Default)
                .frame(width: 109, height: 109)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 1.0))
                .onAppear {
                  withAnimation(.linear(duration: 0.05)) {
                    animatedProgress = progress
                  }
                }
                .onChange(of: progress) { newValue in
                  withAnimation(.linear(duration: 0.05)) {
                    animatedProgress = newValue
                  }
                }
            }
          }
          .frame(width: 80, height: 80)
      }
      if buttonState == .completed {
        HStack(spacing: 8) {
          Button {
            if isAccess {
              disableUploadButton = true
              if musicVM.isTrimmed {
                editorVM.currentVideo?.setVolume(0)
              }
            }
            Task {
              if !isAccess {
                return
              }
              UploadProgressViewModel.shared.uploadStarted()
              tabbarModel.tabSelectionNoAnimation = .main
              tabbarModel.tabSelection = .main
              alertViewModel.onFullScreenCover = false
            }
            Task {
              if isAccess {
                if let video = editorVM.currentVideo {
                  let exporterVM = VideoExporterViewModel(video: video, musicVolume: musicVM.musicVolume)
                  await exporterVM.action(.save, start: video.rangeDuration.lowerBound)
                  if let thumbnail = exporterVM.thumbnailImage {
                    UploadProgressViewModel.shared.thumbnail = Image(uiImage: thumbnail)
                  }
                  dismiss()
                  if let url = exporterVM.renderedVideoURL {
                    VideoCompression
                      .compressh264Video(from: url, cache: .forceDelete, preferred: .quantity(ratio: 1.0)) { item, error in
                        if let error {
                          apiViewModel.uploadContent(
                            video: exporterVM.videoData,
                            thumbnail: exporterVM.thumbnailData,
                            caption: "",
                            musicID: musicVM.musicInfo?.musicID ?? 0,
                            videoLength: video.totalDuration,
                            aspectRatio: exporterVM.aspectRatio,
                            hashtags: [""])
                        } else {
                          if let item {
                            var data = Data()
                            if let videoData = try? Data(contentsOf: item) {
                              data = videoData
                            }
                            apiViewModel.uploadContent(
                              video: data,
                              thumbnail: exporterVM.thumbnailData,
                              caption: "",
                              musicID: musicVM.musicInfo?.musicID ?? 0,
                              videoLength: video.totalDuration,
                              aspectRatio: exporterVM.aspectRatio,
                              hashtags: [""])
                          }
                        }
                      }
                  }
                  if let renderedVideoURL = exporterVM.renderedVideoURL {
                    FileManager.default.removefileExists(for: renderedVideoURL)
                  }
                  exporterVM.renderedVideoURL = nil
                  exporterVM.renderedVideoURL = nil
                }
              } else {
                uploadBottomSheetPosition = .dynamic
              }
            }
          } label: {
            Text(ContentWords().uploadNow)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background {
                glassMorphicView(cornerRadius: 24)
                  .overlay {
                    RoundedRectangle(cornerRadius: 24)
                      .stroke(LinearGradient.Border_Glass)
                  }
              }
          }
          Button {
            if isAccess || musicVM.musicInfo != nil {
              guestUploadModel.goDescriptionTagView = true
            } else {
              uploadBottomSheetPosition = .dynamic
            }
          } label: {
            Text(CommonWords().next)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background {
                Capsule()
                  .foregroundColor(Color.Primary_Default)
              }
          }
        }
        .foregroundStyle(Color.LabelColor_Primary_Dark)
      }
    }
    .padding(.bottom, buttonState.bottomPadding)
    .padding(.horizontal, buttonState.horizontalPadding)
    .onTapGesture {
      switch buttonState {
      case .idle:
        withAnimation(.smooth(duration: 0.5)) {
          buttonState = .recording
        }
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
      case .recording:
        buttonState = .completed
        viewModel.aespaSession.stopRecording { result in
          switch result {
          case .success(let videoURL):
            setVideo(videoURL)
          case .failure(let error):
            WhistleLogger.logger.debug("Error: \(error)")
          }
        }
        stopRecordingTimer()
        isRecording = false
      case .completed:
        buttonState = .idle
      }
    }
  }
}
