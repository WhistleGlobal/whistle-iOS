//
//  VolumeSliderSheetView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - VolumeSliderSheetView

struct VolumeSliderSheetView: View {
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var editorVM: VideoEditorViewModel
  @ObservedObject var musicVM: MusicViewModel

  @State private var videoVolume: Float = 1.0
  @State private var audioVolume: Float = 1.0

  var videoValue: Binding<Float> {
//    editorVM.isSelectVideo ? $videoVolume : $audioVolume
    $videoVolume
  }

  var audioValue: Binding<Float> {
    $audioVolume
  }

  let tapDismiss: (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      subtitleText(text: "원본 사운드")
      UniSlider(
        value: videoValue,
        in: 0 ... 1,
        onChanged: {
          onChange()
        },
        track: {
          RoundedRectangle(cornerRadius: 12)
            .foregroundColor(Color.Dim_Default)
            .frame(width: UIScreen.getWidth(361), height: UIScreen.getHeight(56))
        },
        thumb: {
          RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.white)
            .shadow(radius: 20 / 1)
        },
        thumbSize: CGSize(width: UIScreen.getWidth(16), height: UIScreen.getHeight(56)))
        .frame(width: UIScreen.getWidth(361), height: UIScreen.getHeight(56))
        .overlay(alignment: .leading) {
          Text("\(Int(videoValue.wrappedValue * 100))")
            .fontSystem(fontDesignSystem: .subtitle3)
            .vCenter()
            .padding(.leading, UIScreen.getWidth(24))
        }
      if musicVM.isTrimmed {
        subtitleText(text: "추가된 음악 사운드")
          .padding(.top, 12)
        RoundedRectangle(cornerRadius: 12)
          .foregroundColor(Color.Gray30_Light)
          .frame(width: UIScreen.getWidth(361), height: UIScreen.getHeight(56))
          .overlay(alignment: .leading) {
            Text("100")
              .fontSystem(fontDesignSystem: .subtitle3)
              .vCenter()
              .padding(.leading, UIScreen.getWidth(24))
          }
      }
      completeButton()
    }
    .padding(.top, UIScreen.getHeight(20))
    .padding(.bottom, UIScreen.getHeight(32))
    .onAppear {
      setValue()
    }
  }
}

// MARK: - AudioSheetView_Previews

struct AudioSheetView_Previews: PreviewProvider {
  static var previews: some View {
    VolumeSliderSheetView(videoPlayer: VideoPlayerManager(), editorVM: VideoEditorViewModel(), musicVM: MusicViewModel()) { }
  }
}

extension VolumeSliderSheetView {
  @ViewBuilder
  func subtitleText(text: String) -> some View {
    Text(text)
      .fontSystem(fontDesignSystem: .subtitle2_KO)
      .foregroundStyle(Color.Gray10_Dark)
  }

  @ViewBuilder
  func completeButton() -> some View {
    Text("음량 설정")
      .fontSystem(fontDesignSystem: .subtitle2_KO)
      .foregroundStyle(Color.white)
      .padding(.horizontal, UIScreen.getWidth(150))
      .padding(.vertical, UIScreen.getHeight(12))
      .background(Capsule().fill(Color.Blue_Default))
      .onTapGesture {
        tapDismiss?()
      }
  }
}

extension VolumeSliderSheetView {
  private func setValue() {
    guard let video = editorVM.currentVideo else { return }
    if editorVM.isSelectVideo {
      videoVolume = video.volume
    }
//    else if let audio = video.audio {
//      audioVolume = audio.volume
//    }
    if musicVM.isTrimmed {
      audioVolume = musicVM.musicVolume
    }
  }

  private func onChange() {
    if editorVM.isSelectVideo {
      editorVM.currentVideo?.setVolume(videoVolume)
//      musicVM.setVolume(value: audioVolume)
    }
//    else {
//      editorVM.currentVideo?.audio?.setVolume(audioVolume)
//    }
    videoPlayer.setVolume(editorVM.isSelectVideo, value: videoValue.wrappedValue)
    if musicVM.isTrimmed {
      musicVM.setVolume(value: audioValue.wrappedValue)
      editorVM.currentVideo?.audio?.setVolume(audioValue.wrappedValue)
    }
  }
}
