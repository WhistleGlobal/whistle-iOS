//
//  PlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVKit
import Combine
import Foundation
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ViewLifecycleDelegate

protocol ViewLifecycleDelegate {
  func onAppear()
  func onDisappear()
}

// MARK: - MaintabSelection

enum MaintabSelection: String {
  case left
  case right
}

// MARK: - PlayerView

struct PlayerView: View {
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  let lifecycleDelegate: ViewLifecycleDelegate?
  @State var newId = UUID()
  @State var mainTabSelection: MaintabSelection = .left
  @Binding var showDialog: Bool
  @Binding var showPasteToast: Bool
  @Binding var showBookmarkToast: Bool
  @Binding var showFollowToast: (Bool, String)
  @Binding var currentVideoUserId: Int
  @Binding var currentVideoContentId: Int

  var body: some View {
    VStack(spacing: 0) {
      ForEach(apiViewModel.contentList, id: \.self) { content in
        TabView(selection: $mainTabSelection) {
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
                  .onChange(of: mainTabSelection) { _ in
                    if player.rate != 0.0 {
                      player.pause()
                    } else {
                      player.play()
                    }
                  }
              }
            }
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
            LinearGradient(
              colors: [.clear, .black.opacity(0.24)],
              startPoint: .center,
              endPoint: .bottom)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .allowsHitTesting(false)
            if tabbarModel.tabWidth != 56 {
              userInfo(
                contentId: content.contentId ?? 0,
                userName: content.userName ?? "",
                profileImg: content.profileImg ?? "",
                isFollowed:
                Binding(get: {
                  content.isFollowed
                }, set: { newValue in
                  content.isFollowed = newValue
                }),
                caption: content.caption ?? "",
                musicTitle: content.musicTitle ?? "",
                isWhistled: Binding(get: {
                  content.isWhistled
                }, set: { newValue in
                  content.isWhistled = newValue
                }),
                whistleCount:
                Binding(get: {
                  content.whistleCount ?? 0
                }, set: { newValue in
                  content.whistleCount = newValue
                }))
            }
          }
          .ignoresSafeArea()
          .tag(MaintabSelection.left)
          UserProfileView(userId: currentVideoUserId)
            .environmentObject(apiViewModel)
            .environmentObject(tabbarModel)
            .tag(MaintabSelection.right)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
    contentId: Int,
    userName: String,
    profileImg: String,
    isFollowed: Binding<Bool>,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    whistleCount: Binding<Int>)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            NavigationLink {
              UserProfileView(userId: currentVideoUserId)
                .environmentObject(apiViewModel)
                .environmentObject(tabbarModel)
            } label: {
              Group {
                profileImageView(url: profileImg, size: 36)
                  .padding(.trailing, 12)
                Text(userName)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .subtitle1)
                  .padding(.trailing, 16)
              }
            }
            if userName != apiViewModel.myProfile.userName {
              Button {
                Task {
                  if isFollowed.wrappedValue {
                    await apiViewModel.unfollowUser(userId: currentVideoUserId)
                    showFollowToast = (true, "\(userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followUser(userId: currentVideoUserId)
                    showFollowToast = (true, "\(userName)님을 팔로우 중")
                  }
                  isFollowed.wrappedValue.toggle()
                  apiViewModel.contentList = apiViewModel.contentList.map { item in
                    let mutableItem = item
                    if mutableItem.userId == currentVideoUserId {
                      mutableItem.isFollowed = isFollowed.wrappedValue
                    }
                    return mutableItem
                  }
                  apiViewModel.postFeedPlayerChanged()
                }
              } label: {
                Text(isFollowed.wrappedValue ? "following" : "follow")
                  .fontSystem(fontDesignSystem: .caption_SemiBold)
                  .foregroundColor(.Gray10)
                  .background {
                    Capsule()
                      .stroke(Color.Border_Default, lineWidth: 1)
                      .frame(width: isFollowed.wrappedValue ? 78 : 60, height: 26)
                  }
                  .frame(width: isFollowed.wrappedValue ? 78 : 60, height: 26)
              }
            }
          }
          HStack(spacing: 0) {
            Text(caption)
              .fontSystem(fontDesignSystem: .body2_KO)
              .foregroundColor(.white)
          }
          Label(musicTitle, systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
        }
        Spacer()
        VStack(spacing: 0) {
          Spacer()
          Button {
            Task {
              if isWhistled.wrappedValue {
                await apiViewModel.actionWhistleCancel(contentId: contentId)
                whistleCount.wrappedValue -= 1
              } else {
                await apiViewModel.actionWhistle(contentId: contentId)
                whistleCount.wrappedValue += 1
              }
              isWhistled.wrappedValue.toggle()
              apiViewModel.postFeedPlayerChanged()
            }
          } label: {
            VStack(spacing: 0) {
              Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 26)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
                .padding(.bottom, 24)
            }
          }
          Button {
            showPasteToast = true
            UIPasteboard.general.setValue(
              "복사할 링크입니다.",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .resizable()
              .scaledToFit()
              .frame(width: 25, height: 32)
              .foregroundColor(.Gray10)
              .padding(.bottom, 24)
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .resizable()
              .scaledToFit()
              .frame(width: 30, height: 25)
              .foregroundColor(.Gray10)
          }
        }
      }
    }
    .padding(.bottom, 112)
    .padding(.horizontal, 20)
  }
}
