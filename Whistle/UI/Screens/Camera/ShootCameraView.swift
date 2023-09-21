//  ShootCameraView.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import AVFoundation
import AVKit
import SwiftUI

struct ShootCameraView: View {
  @StateObject var viewModel = ShootCameraViewModel()
  @State private var buttonState: CameraButtonState = .idle
  @State private var recordedVideoURL: URL?
  
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
          // 완료 상태에서 녹화한 동영상을 자동으로 재생
          if let recordedVideoURL = recordedVideoURL {
            PlayVideo(url: recordedVideoURL)
          }
          
        default:
          Button(action: {
            // 토글 버튼 상태
            switch buttonState {
            case .idle:
              buttonState = .recording
              viewModel.startRecording()
              
            case .recording:
              buttonState = .completed
              viewModel.stopRecording()
              
            case .completed:
              buttonState = .idle
              resetRecordedVideoURL()
            }
          }) {
            CameraButtonView(state: buttonState)
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
}

struct PlayVideo: UIViewControllerRepresentable {
  let url: URL
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<PlayVideo>) -> AVPlayerViewController {
    let player = AVPlayer(url: url)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    playerViewController.showsPlaybackControls = false  // 컨트롤 숨기기
    playerViewController.player?.play()  // 자동 재생
    playerViewController.player?.actionAtItemEnd = .none  // 비디오 반복 재생
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
      player.seek(to: CMTime.zero)
      player.play()
    }
    return playerViewController
  }
  
  func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<PlayVideo>) {}
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
        ZStack {
          Circle()
            .foregroundColor(.Dim_Thick)
            .frame(width: 114, height: 114, alignment: .center)
          
          Rectangle()
            .foregroundColor(.White)
            .cornerRadius(8)
            .frame(width: 36, height: 36, alignment: .center)
        }
        
      case .completed:
        ZStack {
          Circle()
            .stroke(lineWidth: 4)
            .foregroundColor(.White)
            .frame(width: 84, height: 84, alignment: .center)
          
          Circle()
            .foregroundColor(.Primary_Default)
            .frame(width: 72, height: 72, alignment: .center)
          
          Image(systemName: "checkmark")
            .foregroundColor(.White)
            .frame(width: 48, height: 48)
        }
      }
    }
  }
}

#Preview {
  ShootCameraView()
}
