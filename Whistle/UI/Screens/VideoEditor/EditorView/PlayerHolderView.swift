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
  var scale: CGFloat = 0.5

  var body: some View {
    VStack(spacing: 6) {
      ZStack(alignment: .bottom) {
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
      .allFrame()
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
        GeometryReader { proxy in
          ZStack {
            EditablePlayerView(player: videoPlayer.videoPlayer)
              .frame(width: 200, height: 360)
              .cornerRadius(12)
              .hCenter()
              .vCenter()
              .overlay {
                RoundedRectangle(cornerRadius: 12)
                  .strokeBorder(Color.Border_Default_Dark, lineWidth: 1)
                  .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
              }
            if !videoPlayer.isPlaying {
              Image(systemName: "play.fill")
                .font(.system(size: 24))
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            }
          }
          .onTapGesture {
            videoPlayer.action(video)
          }
          .scaleEffect(editorVM.frames.scale)
          .onAppear {
            Task {
              guard let size = await editorVM.currentVideo?.asset.naturalSize() else { return }
              editorVM.currentVideo?.frameSize = size
              editorVM.currentVideo?.geometrySize = proxy.size
            }
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
        Text((videoPlayer.currentTime - video.rangeDuration.lowerBound).formatterTimeString()) +
          Text("/") +
          Text(Int(video.totalDuration).secondsToTime())
      }
      .font(.caption2)
      .foregroundColor(.white)
      .frame(width: 80)
      .padding(5)
      .background(Color(.black).opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
      .padding()
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
