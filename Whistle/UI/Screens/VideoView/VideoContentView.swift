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
import ReverseMask
import SwiftUI

// MARK: - VideoContentView

struct VideoContentView: View {

  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel

  @State var isRecording = false
  @State var isFront = false
  @State var isFlashOn = false

  @State var showSetting = false
  @State var showGallery = false
  @State var showPreparingView = false

  @State private var buttonState: CameraButtonState = .idle
  @State var captureMode: AssetType = .video
  @State private var animatedProgress = 0.0
  @ObservedObject private var viewModel = VideoContentViewModel()
  @State var isPresented = false
  @State var count: CGFloat = 0
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var selectedSec: SelectedSecond = .sec3
  @State var timerSec = (8, false)
  @State var dragOffset: CGFloat = 0
  @State private var recordingDuration: TimeInterval = 0
  @State private var recordingTimer: Timer?
  private let maxRecordingDuration: TimeInterval = 15
  @State var isImagePickerClosed = PassthroughSubject<Bool, Never>()
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase

  var barSpacing: CGFloat {
    CGFloat((UIScreen.width - 32 - 12 - (14 * 6)) / 15)
  }

  var defaultWidth: CGFloat {
    CGFloat(6 + (6 + barSpacing) * 8)
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      if isPresented {
        PickerConfigViewControllerWrapper(isImagePickerClosed: $isImagePickerClosed)
      }
      viewModel.preview
        .padding(.bottom, 64)
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity)
        .allowsHitTesting(false)
      VStack {
        HStack(spacing: 24) {
          Button {
            withAnimation {
              tabbarModel.tabSelectionNoAnimation = .main
              tabbarModel.tabSelection = .main
            }
          } label: {
            Image(systemName: "xmark")
              .resizable()
              .scaledToFit()
              .frame(width: 20)
              .foregroundColor(.white)
          }
          Spacer()
          Button {
            bottomSheetPosition = .absolute(406)
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "clock")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .contentShape(Circle())
              if timerSec.1 {
                Text("\(timerSec.0)초")
                  .fontSystem(fontDesignSystem: .subtitle3_KO)
                  .foregroundColor(.white)
              }
            }
          }
          .frame(width: timerSec.1 ? 89 : 36, height: 36)
          .background {
            if timerSec.1 {
              Capsule()
                .foregroundColor(Color.Primary_Default)
                .frame(width: 89, height: 36)
            } else {
              glassMoriphicCircleView(width: 36, height: 36)
                .overlay {
                  Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)
                }
            }
          }
          Button {
            toggleFlash()
          } label: {
            Image(systemName: isFlashOn ? "bolt" : "bolt.slash.fill")
              .font(.system(size: 16))
              .foregroundColor(.white)
              .contentShape(Circle())
          }
          .frame(width: 36, height: 36)
          .background {
            if isFlashOn {
              Circle()
                .frame(width: 36)
                .foregroundColor(Color.Primary_Default)
            } else {
              glassMoriphicCircleView(width: 36, height: 36)
                .overlay {
                  Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)
                }
            }
          }
          Spacer()
          Spacer().frame(width: 20)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        Spacer()
        HStack(spacing: 0) {
          // Album thumbnail + button
          Button(action: { isImagePickerClosed.send(true) }) {
            let coverImage = (
              captureMode == .video
                ? viewModel.videoAlbumCover
                : viewModel.photoAlbumCover)
              ?? Image("")
            roundRectangleShape(with: coverImage, size: 56)
          }
          .shadow(radius: 5)
          .contentShape(Rectangle())
          .onReceive(isImagePickerClosed) { value in
            isPresented = value
          }

          Spacer()
          // Shutter + button
          recordingButton(
            state: buttonState,
            timerText: timeStringFromTimeInterval(recordingDuration),
            progress: min(recordingDuration / maxRecordingDuration, 1.0))
          Spacer()
          // Position change + button
          Button(action: {
            viewModel.aespaSession.position(to: isFront ? .back : .front)
            isFront.toggle()
          }) {
            VStack(spacing: 8) {
              ZStack {
                glassMoriphicCircleView(width: 56, height: 56)
                  .overlay {
                    Circle()
                      .stroke(lineWidth: 1)
                      .foregroundStyle(LinearGradient.Border_Glass)
                  }
                Image(systemName: "arrow.triangle.2.circlepath")
                  .resizable()
                  .scaledToFit()
                  .foregroundColor(.white)
                  .frame(width: 27, height: 20)
              }
              Text("화면 전환")
                .foregroundColor(.white)
            }
          }
          .contentShape(Rectangle())
        }
        .frame(height: 114)
        .padding(.horizontal, 42)
        .padding(.bottom, 64)
      }
      .opacity(showPreparingView ? 0 : 1)
      if showPreparingView {
        Circle()
          .trim(from: 0, to: min(count / CGFloat(timerSec.0), 1.0))
          .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .square))
          .frame(width: 84)
          .rotationEffect(Angle(degrees: -90))
          .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
        Text("\(Int(count))")
          .fontSystem(fontDesignSystem: .largeTitle_Expanded)
          .foregroundColor(.white)
      }
    }
    .navigationBarBackButtonHidden()
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
      switchablePositions: [.hidden, .absolute(406)])
    {
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
                      if selectedSec == .sec10 {
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
                      if selectedSec == .sec3 {
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
                  timerSec.0 = 3
                  let multiplier = 6 + barSpacing
                  selectedSec = .sec3
                  dragOffset = -5.0 * CGFloat(multiplier)
                }
              } label: {
                Text("3s")
                  .fontSystem(fontDesignSystem: .subtitle3_KO)
                  .foregroundColor(selectedSec == .sec3 ? .White : Color.LabelColor_DisablePlaceholder)
                  .frame(width: 58, height: 30)
              }
              .frame(width: 58, height: 30)
              Button {
                withAnimation {
                  timerSec.0 = 10
                  let multiplier = 6 + barSpacing
                  dragOffset = 2.0 * CGFloat(multiplier)
                  selectedSec = .sec10
                }
              } label: {
                Text("10s")
                  .fontSystem(fontDesignSystem: .subtitle3_KO)
                  .foregroundColor(selectedSec == .sec10 ? .White : Color.LabelColor_DisablePlaceholder)
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
                ForEach(0..<14) { i in
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
                              case .min..<6 + Int(barSpacing):
                                withAnimation {
                                  dragOffset = -8.0 * CGFloat(multiplier)
                                  timerSec.0 = 0
                                }
                              case 6 - Int(barSpacing)..<Int(multiplier) + Int(barSpacing):
                                withAnimation {
                                  dragOffset = -7.0 * CGFloat(multiplier)
                                  timerSec.0 = 1
                                }
                              case Int(multiplier) - Int(barSpacing)..<Int(2 * multiplier) + Int(barSpacing):
                                withAnimation {
                                  dragOffset = -6.0 * CGFloat(multiplier)
                                  timerSec.0 = 2
                                }
                              case Int(2 * multiplier) - Int(barSpacing)..<Int(3 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = -5.0 * CGFloat(multiplier)
                                  timerSec.0 = 3
                                }
                              case Int(3 * multiplier) - Int(barSpacing)..<Int(4 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = -4.0 * CGFloat(multiplier)
                                  timerSec.0 = 4
                                }
                              case Int(4 * multiplier) - Int(barSpacing)..<Int(5 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = -3.0 * CGFloat(multiplier)
                                  timerSec.0 = 5
                                }
                              case Int(5 * multiplier) - Int(barSpacing)..<Int(6 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = -2.0 * CGFloat(multiplier)
                                  timerSec.0 = 6
                                }
                              case Int(6 * multiplier) - Int(barSpacing)..<Int(7 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = -CGFloat(multiplier)
                                  timerSec.0 = 7
                                }
                              case Int(7 * multiplier) - Int(barSpacing)..<Int(8 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 0.0
                                  timerSec.0 = 8
                                }
                              case Int(8 * multiplier) - Int(barSpacing)..<Int(9 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = CGFloat(multiplier)
                                  timerSec.0 = 9
                                }
                              case Int(9 * multiplier) - Int(barSpacing)..<Int(10 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 2.0 * CGFloat(multiplier)
                                  timerSec.0 = 10
                                }
                              case Int(10 * multiplier) - Int(barSpacing)..<Int(11 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 3.0 * CGFloat(multiplier)
                                  timerSec.0 = 11
                                }
                              case Int(11 * multiplier) - Int(barSpacing)..<Int(12 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 4.0 * CGFloat(multiplier)
                                  timerSec.0 = 12
                                }
                              case Int(12 * multiplier) - Int(barSpacing)..<Int(13 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 5.0 * CGFloat(multiplier)
                                  timerSec.0 = 13
                                }
                              case Int(13 * multiplier) - Int(barSpacing)..<Int(14 * multiplier) +
                                Int(barSpacing):
                                withAnimation {
                                  dragOffset = 6.0 * CGFloat(multiplier)
                                  timerSec.0 = 14
                                }
                              case Int(14 * multiplier) - Int(barSpacing)...Int.max:
                                withAnimation {
                                  dragOffset = 7.0 * CGFloat(multiplier)
                                  timerSec.0 = 15
                                }
                              default:
                                log("")
                              }
                            })
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
          timerSec.1 = true
          bottomSheetPosition = .hidden
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
        .padding(.horizontal, 16)
        Spacer()
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

extension VideoContentView {
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
      Text("갤러리")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Primary_Dark)
    }
  }

  @ViewBuilder
  func recordingButtonShape(width: CGFloat) -> some View {
    ZStack {
      Circle()
        .strokeBorder(isRecording ? .red : .white, lineWidth: 3)
        .frame(width: width)

      Circle()
        .fill(isRecording ? .red : .white)
        .frame(width: width * 0.8)
    }
    .frame(height: width)
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

extension VideoContentView {
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
    count = CGFloat(timerSec.0)
    showPreparingView = true
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      withAnimation(.linear(duration: 0.5)) {
        count -= 1
      }
      if count == 0 {
        showPreparingView = false
        timerSec.0 = 0
        timerSec.1 = false
        buttonState = .recording
        viewModel.aespaSession.startRecording()
        startRecordingTimer()
        isRecording = true
      }
    }
  }

  private func startRecordingTimer() {
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      recordingDuration += 1
      if recordingDuration >= maxRecordingDuration {
        buttonState = .completed
        viewModel.aespaSession.stopRecording()
        stopRecordingTimer()
        isRecording = false
      }
    }
  }

  private func stopRecordingTimer() {
    recordingTimer?.invalidate()
    recordingTimer = nil
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
            buttonState = .recording
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
              .animation(.linear(duration: 0.1))
            Rectangle()
              .foregroundColor(.White)
              .cornerRadius(8)
              .frame(width: 36, height: 36, alignment: .center)
          }
        }
        .onAppear {
          withAnimation(.linear(duration: 0.5)) {
            animatedProgress = progress
          }
        }
        .onChange(of: progress) { newValue in
          withAnimation(.linear(duration: 0.5)) {
            animatedProgress = newValue
          }
        }
        .onTapGesture {
          buttonState = .completed
          viewModel.aespaSession.stopRecording()
          stopRecordingTimer()
          isRecording = false
        }
      case .completed:

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
    }
  }
}
