//
//  MusicInfo.swift
//  Whistle
//
//  Created by 박상원 on 11/5/23.
//

import Kingfisher
import SwiftUI
// MARK: - MusicInfo

struct MusicInfo: View {
  @ObservedObject var musicVM: MusicViewModel
  @Binding var showMusicTrimView: Bool

  var showXmark = true
  let onClick: () -> Void
  let onDelete: () -> Void

  var body: some View {
    if let music = musicVM.musicInfo {
      HStack(spacing: 0) {
        KFImage(URL(string: music.albumCover))
          .cancelOnDisappear(true)
          .placeholder {
            Image("noVideo")
              .resizable()
              .scaledToFill()
          }
          .retry(maxCount: 3, interval: .seconds(0.5))
          .resizable()
          .frame(width: UIScreen.getWidth(32), height: UIScreen.getWidth(32))
          .cornerRadius(4)
          .padding(.leading, 8)
          .padding(.vertical, 8)
          .padding(.trailing, 12)
        Text(music.musicTitle)
          .frame(maxWidth: UIScreen.getWidth(90))
          .padding(.trailing, 12)
          .lineLimit(1)
          .truncationMode(.tail)
          .fontSystem(fontDesignSystem: .body1)
          .contentShape(Rectangle())
          .onTapGesture {
            showMusicTrimView = true
          }
        if showXmark {
          Rectangle()
            .fill(Color.Border_Default_Dark)
            .frame(width: 1)
            .padding(.vertical, 8)
          Button {
            onDelete()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 16))
              .frame(width: UIScreen.getWidth(32), height: UIScreen.getWidth(32))
              .contentShape(Rectangle())
              .padding(.horizontal, 4)
              .padding(.vertical, 8)
          }
        }
      }
      .foregroundStyle(.white)
      .fixedSize()
      .background(disabledGlass(cornerRadius: 8))
      .padding(.top, 8)
    } else {
      HStack {
        Image(systemName: "music.note")
        Text(VideoEditorWords().addMusic)
          .frame(maxWidth: UIScreen.getWidth(90))
          .lineLimit(1)
          .truncationMode(.tail)
          .fontSystem(fontDesignSystem: .body1)
          .contentShape(Rectangle())
      }
      .foregroundStyle(.white)
      .fixedSize()
      .padding(.horizontal, 16)
      .padding(.vertical, 6)
      .background(disabledGlass(cornerRadius: 8))
      .onTapGesture {
        onClick()
      }
      .padding(.top, 8)
    }
  }
}
