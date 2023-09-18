//
//  PlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVKit
import Foundation
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ViewLifecycleDelegate

protocol ViewLifecycleDelegate {
  func onAppear()
  func onDisappear()
}

// MARK: - PlayerView

struct PlayerView: View {
  @EnvironmentObject var apiViewModel: APIViewModel
  let lifecycleDelegate: ViewLifecycleDelegate?
  @State var newId = UUID()
  @Binding var showDialog: Bool

  var body: some View {
    VStack(spacing: 0) {
      ForEach(apiViewModel.contentList, id: \.self) { content in
        ZStack {
          Color.clear.overlay {
            if let url = content.thumbnailUrl {
              KFImage.url(URL(string: url))
                .placeholder {
                  Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .cacheMemoryOnly()
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let player = content.player {
              Player(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          }
          .onReceive(apiViewModel.publisher) { id in
            newId = id
          }
          .id(newId)
          userInfo(
            userName: content.userName ?? "",
            isFollowed: content.isFollowed ?? false,
            caption: content.caption ?? "",
            musicTitle: content.musicTitle ?? "",
            whistleCount: content.whistleCount ?? 0)
        }
      }
    }
    .ignoresSafeArea()
    .onAppear {
      lifecycleDelegate?.onAppear()
    }
    .onDisappear {
      lifecycleDelegate?.onDisappear()
    }
  }
}

extension PlayerView {

  @ViewBuilder
  func userInfo(
    userName: String,
    isFollowed _: Bool,
    caption: String,
    musicTitle: String,
    whistleCount: Int)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Circle()
              .frame(width: 36, height: 36)
              .padding(.trailing, 12)
            Text(userName)
              .foregroundColor(.white)
              .fontSystem(fontDesignSystem: .subtitle1)
              .padding(.trailing, 16)
            Text("팔로우")
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .foregroundColor(.Gray10)
              .background {
                RoundedRectangle(cornerRadius: 6)
                  .stroke(
                    Color.Border_Default,
                    lineWidth: 1)
                  .frame(width: 50, height: 26)
              }
              .frame(width: 50, height: 26)
          }
          HStack(spacing: 0) {
            Text(caption)
              .fontSystem(fontDesignSystem: .body2_KO)
              .foregroundColor(.white)
          }
          Label(musicTitle, systemImage: "music.quarternote.3")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
        }
        Spacer()
        VStack(spacing: 0) {
          Spacer()
          Image(systemName: "music.note")
            .resizable()
            .scaledToFit()
            .frame(width: 36, height: 36)
            .foregroundColor(.Gray10)
            .padding(.bottom, 2)
          Text("\(whistleCount)")
            .foregroundColor(.Gray10)
            .fontSystem(fontDesignSystem: .caption_Regular)
            .padding(.bottom, 24)

          Button {
            UIPasteboard.general.setValue(
              "복사할 링크입니다.",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            VStack(spacing: 0) {
              Image(systemName: "square.and.arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 38)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("공유")
                .foregroundColor(.Gray10)
                .padding(.bottom, 24)
                .fontSystem(fontDesignSystem: .caption_Regular)
            }
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
            showDialog = true
          } label: {
            VStack(spacing: 0) {
              Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 38)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("더보기")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
            }
          }
        }
      }
    }
    .padding(.bottom, 112)
    .padding(.horizontal, 20)
  }
}
