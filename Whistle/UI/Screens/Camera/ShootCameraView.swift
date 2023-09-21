//
//  ShootCameraView.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import AVFoundation
import AVKit
import SwiftUI

// MARK: - ShootCameraView

struct ShootCameraView: View {
  @StateObject var viewModel = ShootCameraViewModel()
  @State private var buttonState: CameraButtonState = .idle
  @State private var recordedVideoURL: URL?
  @State private var recordingDuration: TimeInterval = 0
  @State private var recordingTimer: Timer?
  private let maxRecordingDuration: TimeInterval = 15 // 최대 녹화 시간 (15초)

  var body: some View {
    ZStack {
      // 카메라 프리뷰 또는 녹화된 동영상 프리뷰 표시
      if let videoURL = viewModel.recordedVideoURL {
        PlayVideo(url: videoURL)
      } else {
        viewModel.preview?
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
          .edgesIgnoringSafeArea(.all)
      }

      VStack {
        Spacer()
        Spacer()

        switch buttonState {
        case .completed:
          // 버튼을 투명하게 만들고 배경에 영상 띄우기
          Button(action: {
            // 버튼이 투명하게 되어 동작이 필요 없음
          }) {
            ZStack {
              Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.White)
                .frame(width: 84, height: 84, alignment: .center)

              Circle()
                .foregroundColor(.Primary_Default)
                .frame(width: 72, height: 72, alignment: .center)

              Image(systemName: "checkmark")
                .font(.custom("SFCompactText-Regular", size: 44))
                .foregroundColor(.White)
            }
          }

        default:
          Button(action: {
            // 토글 버튼 상태
            switch buttonState {
            case .idle:
              buttonState = .recording
              viewModel.startRecording()
              startRecordingTimer() // 녹화 타이머 시작

            case .recording:
              buttonState = .completed
              viewModel.stopRecording()
              stopRecordingTimer() // 녹화 타이머 중지

            case .completed:
              buttonState = .idle
              resetRecordedVideoURL()
            }
          }) {
            // 시간을 표시할 버튼
            CameraButtonView(state: buttonState, timerText: timeStringFromTimeInterval(recordingDuration))
          }
          .padding()
        }

        Spacer()
      }
    }
  }

  func resetRecordedVideoURL() {
    recordedVideoURL = nil
  }

  private func startRecordingTimer() {
    recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      recordingDuration += 1

      // 녹화 시간이 최대 녹화 시간을 초과하면 녹화 중지
      if recordingDuration >= maxRecordingDuration {
        buttonState = .completed
        viewModel.stopRecording()
        stopRecordingTimer() // 녹화 타이머 중지
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

// MARK: - PlayVideo

struct PlayVideo: UIViewControllerRepresentable {
  let url: URL

  func makeUIViewController(context _: UIViewControllerRepresentableContext<PlayVideo>) -> AVPlayerViewController {
    let player = AVPlayer(url: url)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    playerViewController.showsPlaybackControls = false // 컨트롤 숨기기
    playerViewController.player?.play() // 자동 재생
    playerViewController.player?.actionAtItemEnd = .none // 비디오 반복 재생
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
      player.seek(to: CMTime.zero)
      player.play()
    }
    return playerViewController
  }

  func updateUIViewController(_: AVPlayerViewController, context _: UIViewControllerRepresentableContext<PlayVideo>) { }
}

// MARK: - CameraButtonState

enum CameraButtonState {
  case idle
  case recording
  case completed
}

// MARK: - CameraButtonView

struct CameraButtonView: View {
  let state: CameraButtonState
  let timerText: String

  var body: some View {
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

      case .recording:

        VStack {
          // 시간을 표시할 텍스트
          Text(timerText)
            .font(.custom("SFProText-Semibold", size: 16))
            .foregroundColor(.Gray10)

          ZStack {
            Circle()
              .foregroundColor(.Dim_Thick)
              .frame(width: 114, height: 114, alignment: .center)

            Rectangle()
              .foregroundColor(.White)
              .cornerRadius(8)
              .frame(width: 36, height: 36, alignment: .center)
          }
        }

      case .completed:
        // 투명한 버튼을 위한 빈 ZStack
        ZStack { }
      }
    }
  }
}

#Preview {
  ShootCameraView()
}
