//
//  AudioSheetView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - AudioSheetView

struct AudioSheetView: View {
  @State private var videoVolume: Float = 1.0
  @State private var audioVolume: Float = 1.0
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var editorVM: EditorViewModel

  var value: Binding<Float> {
    editorVM.isSelectVideo ? $videoVolume : $audioVolume
  }

  var body: some View {
    HStack {
      Image(systemName: value.wrappedValue > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
      Slider(value: value, in: 0 ... 1) { _ in
        onChange()
      }
      .tint(.white)
      Text("\(Int(value.wrappedValue * 100))")
    }
    .font(.caption)
    .onAppear {
      setValue()
    }
  }
}

// MARK: - AudioSheetView_Previews

struct AudioSheetView_Previews: PreviewProvider {
  static var previews: some View {
    AudioSheetView(videoPlayer: VideoPlayerManager(), editorVM: EditorViewModel())
  }
}

extension AudioSheetView {
  private func setValue() {
    guard let video = editorVM.currentVideo else { return }
    if editorVM.isSelectVideo {
      videoVolume = video.volume
    } else if let audio = video.audio {
      audioVolume = audio.volume
    }
  }

  private func onChange() {
    if editorVM.isSelectVideo {
      editorVM.currentVideo?.setVolume(videoVolume)
    } else {
      editorVM.currentVideo?.audio?.setVolume(audioVolume)
    }
    videoPlayer.setVolume(editorVM.isSelectVideo, value: value.wrappedValue)
  }
}
