//
//  GuestContentPlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import _AVKit_SwiftUI
import AVFoundation
import BottomSheet
import Combine
import Kingfisher
import SwiftUI

// MARK: - GuestContentPlayerView

struct GuestContentPlayerView: View {
  @AppStorage("showGuide") var showGuide = true
  @AppStorage("isAccess") var isAccess = false
  @Environment(\.scenePhase) var scenePhase
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = GuestFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = GuestMainFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared

  @State var newId = UUID()
  @State var timer: Timer? = nil
  @State var viewTimer: Timer? = nil
  @State var showPlayButton = false
  @State var refreshToken = false
  @Binding var currentContentInfo: GuestContent?
  @Binding var index: Int
  @Binding var isChangable: Bool

  let lifecycleDelegate: ViewLifecycleDelegate?

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(apiViewModel.guestFeed.enumerated()), id: \.element) { index, content in
        ZStack {
          Color.black.overlay {
            if let url = apiViewModel.guestFeed[index].thumbnailUrl {
              KFImage.url(URL(string: url))
                .placeholder {
                  Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .resizable()
                .aspectRatio(
                  contentMode: content.aspectRatio ?? 1.0 > Double(15.0 / 9.0)
                    ? .fill
                    : .fit)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let player = feedPlayersViewModel.currentPlayer, index == feedPlayersViewModel.currentVideoIndex {
              ContentPlayer(player: player, aspectRatio: content.aspectRatio)
                .frame(width: UIScreen.width, height: UIScreen.height)
                .onTapGesture(count: 2) {
                  feedMoreModel.bottomSheetPosition = .dynamic
                }
                .onTapGesture {
                  if player.rate == 0.0 {
                    player.play()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  } else {
                    player.pause()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  }
                }
                .onLongPressGesture {
                  HapticManager.instance.impact(style: .medium)
                  feedMoreModel.bottomSheetPosition = .dynamic
                }
                .overlay {
                  if !tabbarModel.isCollpased() {
                    ContentLayer(
                      currentVideoInfo: content,
                      feedMoreModel: GuestMainFeedMoreModel.shared,
                      feedPlayersViewModel: GuestFeedPlayersViewModel.shared,
                      feedArray: apiViewModel.guestFeed,
                      whistleAction: { },
                      refreshToken: $refreshToken)
                      .padding(.bottom, UIScreen.main.nativeBounds.height == 1334 ? 24 : 0)
                  }
                  if feedMoreModel.bottomSheetPosition != .hidden {
                    DimsThick()
                      .onAppear {
                        isChangable = false
                      }
                      .onDisappear {
                        isChangable = true
                      }
                  }
                }
                .onChange(of: tabbarModel.tabSelection) { newValue in
                  if newValue == .main {
                    guard let currentPlayer = feedPlayersViewModel.currentPlayer else {
                      return
                    }
                    currentPlayer.play()
                  } else {
                    feedPlayersViewModel.stopPlayer()
                  }
                }
              playButton(toPlay: player.rate == 0)
                .opacity(showPlayButton ? 1 : 0)
                .allowsHitTesting(false)
            }
            if BlockList.shared.userIds.contains(content.userId ?? 0) {
              KFImage.url(URL(string: content.thumbnailUrl ?? ""))
                .placeholder {
                  Color.black
                }
                .resizable()
                .scaledToFill()
                .blur(radius: 30)
                .overlay {
                  VStack {
                    Image(systemName: "eye.slash.fill")
                      .font(.system(size: 44))
                      .foregroundColor(.Gray10)
                      .padding(.bottom, 26)
                    Text("차단된 계정의 콘텐츠입니다.")
                      .fontSystem(fontDesignSystem: .subtitle1)
                      .foregroundColor(.LabelColor_Primary_Dark)
                      .padding(.bottom, 12)
                    Text("차단된 계정의 모든 콘텐츠는\n회원님의 피드에 노출되지 않습니다.")
                      .multilineTextAlignment(.center)
                      .fontSystem(fontDesignSystem: .body2)
                      .foregroundColor(.LabelColor_Secondary_Dark)
                  }
                }
            }
          }
          .ignoresSafeArea()
        }
        .frame(width: UIScreen.width, height: UIScreen.height)
        .ignoresSafeArea()
      }
      .onReceive(apiViewModel.publisher) { id in
        newId = id
      }
      .id(newId)
    }
    .onAppear {
      GuestUploadModel.shared.isNotAccessRecord = false
      if index == 0 {
        lifecycleDelegate?.onAppear()
      } else {
        feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        if BlockList.shared.userIds.contains(currentContentInfo?.userId ?? 0) {
          return
        }
        feedPlayersViewModel.currentPlayer?.play()
      }
    }
    .onDisappear {
      lifecycleDelegate?.onDisappear()
    }
    .ignoresSafeArea()
    .onChange(of: tabbarModel.tabSelection) { newValue in
      if newValue == .main {
        feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        feedPlayersViewModel.currentPlayer?.play()
        return
      }
    }
  }
}
