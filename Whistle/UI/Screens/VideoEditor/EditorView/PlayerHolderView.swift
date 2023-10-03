//
//  PlayerHolderView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - PlayerHolderView

struct PlayerHolderView: View {
  @Binding var isFullScreen: Bool
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  let videoScale: CGFloat = 16 / 9
  let videoWidth: CGFloat = 203
  var scale: CGFloat = 0.5

  var body: some View {
    VStack(spacing: 0) {
      switch videoPlayer.loadState {
      case .loading:
        ProgressView()
      case .unknown:
        Text("Add new video")
      case .failed:
        Text("Failed to open video")
      case .loaded:
        playerCropView
      }
    }
  }
}

// MARK: - PlayerHolderView_Previews

struct PlayerHolderView_Previews: PreviewProvider {
  static var previews: some View {
    MainEditorView()
      .preferredColorScheme(.dark)
  }
}

extension PlayerHolderView {
  private var playerCropView: some View {
    Group {
      if let video = editorVM.currentVideo {
        ZStack {
          EditablePlayerView(player: videoPlayer.videoPlayer)
            .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
            .cornerRadius(12)
            .hCenter()
            .vCenter()
          if !videoPlayer.isPlaying {
            Image(systemName: "play.fill")
              .font(.system(size: 24))
              .padding(16)
              .background(.ultraThinMaterial)
              .clipShape(Circle())
          }
        }
        .fixedSize()
        .overlay {
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(Color.Border_Default_Dark, lineWidth: 1)
        }
        .onTapGesture {
          videoPlayer.action(video)
        }
        .scaleEffect(editorVM.frames.scale)
        .onAppear {
          Task {
            guard let size = await editorVM.currentVideo?.asset.naturalSize() else { return }
            editorVM.currentVideo?.frameSize = size
          }
        }
      }
      timelineLabel
    }
  }
}

extension PlayerHolderView {
  @ViewBuilder
  private var timelineLabel: some View {
    if let video = editorVM.currentVideo {
      HStack {
        Text("00:00")
          .fontSystem(fontDesignSystem: .subtitle3)
        Spacer()
        Text(min(video.originalDuration, videoPlayer.currentTime).formatterTimeString())
          .fontSystem(fontDesignSystem: .subtitle3)
          .padding(.horizontal, 16)
          .padding(.vertical, 4)
          .background(RoundedRectangle(cornerRadius: 100).fill(Color.Blue_Default))
        Spacer()
        Text(Int(video.originalDuration).secondsToTime())
          .fontSystem(fontDesignSystem: .subtitle3)
      }
      .foregroundColor(.white)
      .padding(16)
    }
  }
}

// MARK: - PlayerControl

struct PlayerControl: View {
  @Binding var isFullScreen: Bool
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  var body: some View {
    VStack(spacing: 6) {
      timeLineControlSection
    }
  }

  @ViewBuilder
  private var timeLineControlSection: some View {
    if let video = editorVM.currentVideo {
      TimeLineView(
        currentTime: $videoPlayer.currentTime,
        isSelectedTrack: $editorVM.isSelectVideo,
        viewState: editorVM.selectedTools?.timeState ?? .empty,
        video: video)
      {
        videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
      } onSetAudio: { audio in
        editorVM.setAudio(audio)
        videoPlayer.setAudio(audio.url)
      }
    }
  }
}
