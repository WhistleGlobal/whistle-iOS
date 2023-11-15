//
//  VolumeSliderSheetView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import BottomSheet
import SwiftUI

// MARK: - VolumeSliderSheetView

struct VolumeSliderSheetView: View {
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var editorVM: VideoEditorViewModel
  @ObservedObject var musicVM: MusicViewModel

  @State private var videoVolume: Float = 1.0
  @State private var audioVolume: Float = 1.0
  @State private var tempVideoVolume: Float = 1.0
  @State private var tempAudioVolume: Float = 1.0
  @Binding var bottomSheetPosition: BottomSheetPosition

  var videoValue: Binding<Float> {
//    editorVM.isSelectVideo ? $videoVolume : $audioVolume
    $tempVideoVolume
  }

  var audioValue: Binding<Float> {
    $tempAudioVolume
  }

  let tapDismiss: (() -> Void)?

  var body: some View {
    VStack(spacing: 0) {
      customNavigationBar
      VStack(spacing: 12) {
        subtitleText(text: VideoEditorWords().originalSound)
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
              .foregroundStyle(Color.gray50Light)
              .fontSystem(fontDesignSystem: .subtitle3)
              .vCenter()
              .padding(.leading, UIScreen.getWidth(24))
          }
        if musicVM.isTrimmed {
          subtitleText(text: VideoEditorWords().musicSound)
            .padding(.top, 12)
          UniSlider(
            value: audioValue,
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
              Text("\(Int(audioValue.wrappedValue * 100))")
                .fontSystem(fontDesignSystem: .subtitle3)
                .foregroundStyle(Color.gray50Light)
                .vCenter()
                .padding(.leading, UIScreen.getWidth(24))
            }
        }
        completeButton()
          .padding(.top, 20)
      }
      .frame(width: UIScreen.getWidth(361))
      .padding(.top, UIScreen.getHeight(20))
    }
    .padding(.bottom, UIScreen.getHeight(50))
    .onAppear {
      setValue()
    }
    .onDisappear {
      cancelVolumeChange()
    }
  }
}

extension VolumeSliderSheetView {
  @ViewBuilder
  func subtitleText(text: LocalizedStringKey) -> some View {
    HStack {
      Text(text)
        .fontSystem(fontDesignSystem: .subtitle2)
        .foregroundStyle(Color.LabelColor_Primary_Dark)
      Spacer()
    }
  }

  @ViewBuilder
  func completeButton() -> some View {
    Text(VideoEditorWords().setVolume)
      .fontSystem(fontDesignSystem: .subtitle2)
      .foregroundStyle(Color.white)
      .frame(width: UIScreen.getWidth(361), height: UIScreen.getHeight(48))
      .background(Capsule().fill(Color.Blue_Default))
      .onTapGesture {
        setVolume()
        tapDismiss?()
      }
  }
}

extension VolumeSliderSheetView {
  private func setValue() {
    guard let video = editorVM.currentVideo else { return }
    if editorVM.isSelectVideo {
      videoVolume = video.volume
      tempVideoVolume = video.volume
    }
//    else if let audio = video.audio {
//      audioVolume = audio.volume
//    }
    if musicVM.isTrimmed {
      audioVolume = musicVM.musicVolume
      tempAudioVolume = musicVM.musicVolume
    }
  }

  private func onChange() {
    if editorVM.isSelectVideo {
      videoPlayer.videoPlayer.volume = tempVideoVolume
//      musicVM.setVolume(value: audioVolume)
    }
//    else {
//      editorVM.currentVideo?.audio?.setVolume(audioVolume)
//    }
//    videoPlayer.setVolume(editorVM.isSelectVideo, value: videoValue.wrappedValue)
    if musicVM.isTrimmed {
      musicVM.player?.volume = tempAudioVolume
    }
  }

  private func setVolume() {
    if editorVM.isSelectVideo {
      videoVolume = tempVideoVolume
      editorVM.currentVideo?.setVolume(tempVideoVolume)
    }

    if musicVM.isTrimmed {
      audioVolume = tempAudioVolume
      musicVM.setVolume(value: tempAudioVolume)
      editorVM.currentVideo?.audio?.setVolume(tempAudioVolume)
    }
  }

  private func cancelVolumeChange() {
    if editorVM.isSelectVideo {
      videoPlayer.videoPlayer.volume = videoVolume
    }

    if musicVM.isTrimmed {
      musicVM.player?.volume = audioVolume
    }
  }

  @ViewBuilder
  var customNavigationBar: some View {
    HStack {
      Spacer()
      Button {
        bottomSheetPosition = .hidden
        editorVM.selectedTools = nil
        cancelVolumeChange()
      } label: {
        Text(CommonWords().cancel)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundStyle(.white)
      }
    }
    .padding(.horizontal, 16)
    .frame(height: 44)
    .overlay {
      Text(VideoEditorWords().mutateVolume)
        .fontSystem(fontDesignSystem: .subtitle1)
        .hCenter()
        .foregroundStyle(.white)
    }
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.Border_Default_Dark)
        .frame(height: 1)
    }
  }
}
