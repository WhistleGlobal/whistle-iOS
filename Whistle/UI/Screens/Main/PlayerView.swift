//
//  PlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVKit
import Foundation
import SwiftUI

// MARK: - ViewLifecycleDelegate

protocol ViewLifecycleDelegate {
  func onAppear()
  func onDisappear()
}

// MARK: - PlayerView

struct PlayerView: View {
  @Binding var videoVM: VideoVM
  let lifecycleDelegate: ViewLifecycleDelegate?

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<$videoVM.videos.count) { i in
        ZStack {
          Color.clear.overlay {
            Player(player: videoVM.videos[i].player)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          userInfo()
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
  func userInfo() -> some View {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Circle()
              .frame(width: 36, height: 36)
              .padding(.trailing, 12)
            Text("aewol")
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
            Text("오늘 친구들이랑 강인리 경기 봤는데 경기 수준 실화냐;;")
              .fontSystem(fontDesignSystem: .body2_KO)
              .foregroundColor(.white)
          }
          Label("사용된 음악 출처", systemImage: "music.quarternote.3")
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
          Text("400")
            .foregroundColor(.Gray10)
            .fontSystem(fontDesignSystem: .caption_Regular)
            .padding(.bottom, 24)
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
    .padding(.bottom, 112)
    .padding(.horizontal, 20)
  }
}
