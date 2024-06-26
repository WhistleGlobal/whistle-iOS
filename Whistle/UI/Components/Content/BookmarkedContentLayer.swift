//
//  BookmarkedContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - BookmarkedContentLayer

struct BookmarkedContentLayer: View {
  @StateObject var currentVideoInfo: Bookmark = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = BookmarkedFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = BookmarkedPlayersViewModel.shared
  @State var isExpanded = false
  @Binding var index: Int
  var whistleAction: () -> Void

  var body: some View {
    ZStack {
      if isExpanded {
        DimsThin()
          .onTapGesture {
            withAnimation {
              isExpanded.toggle()
            }
          }
      }
      VStack(spacing: 0) {
        Spacer()
        HStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 12) {
            Spacer()
            HStack(spacing: 0) {
              if currentVideoInfo.userName != apiViewModel.myProfile.userName, !apiViewModel.bookmark.isEmpty {
                NavigationLink {
                  ProfileView(
                    profileType:
                    apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].userId ?? 0 == apiViewModel.myProfile.userId
                      ? .my
                      : .member,
                    isFirstProfileLoaded: .constant(true),
                    userId: apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
                    .id(UUID())
                } label: {
                  Group {
                    profileImageView(url: currentVideoInfo.profileImg, size: 36)
                      .padding(.trailing, UIScreen.getWidth(8))
                    Text(currentVideoInfo.userName ?? "")
                      .foregroundColor(.white)
                      .fontSystem(fontDesignSystem: .subtitle1)
                      .padding(.trailing, 16)
                  }
                }
                .id(UUID())
              } else {
                Group {
                  profileImageView(url: currentVideoInfo.profileImg, size: 36)
                    .padding(.trailing, 12)
                  Text(currentVideoInfo.userName ?? "")
                    .foregroundColor(.white)
                    .fontSystem(fontDesignSystem: .subtitle1)
                    .padding(.trailing, 16)
                }
              }
              if currentVideoInfo.userName ?? "" != apiViewModel.myProfile.userName {
                Button {
                  Task {
                    if currentVideoInfo.isFollowed {
                      await apiViewModel.followAction(userID: currentVideoInfo.userId ?? 0, method: .delete)
                      toastViewModel.toastInit(message: "\(currentVideoInfo.userName ?? "")님을 팔로우 취소했습니다")
                    } else {
                      await apiViewModel.followAction(userID: currentVideoInfo.userId ?? 0, method: .post)
                      toastViewModel.toastInit(message: "\(currentVideoInfo.userName ?? "")님을 팔로우 중입니다")
                    }
                    currentVideoInfo.isFollowed.toggle()

                    apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                      let mutableItem = item
                      if mutableItem.userId == currentVideoInfo.userId ?? 0 {
                        mutableItem.isFollowed = currentVideoInfo.isFollowed
                      }
                      return mutableItem
                    }
                  }
                } label: {
                  Text(currentVideoInfo.isFollowed ? CommonWords().following : CommonWords().follow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .fontSystem(fontDesignSystem: .caption_SemiBold)
                    .foregroundColor(Color.LabelColor_Primary_Dark)
                    .background {
                      Capsule()
                        .stroke(Color.LabelColor_Primary_Dark, lineWidth: 1)
                    }
                }
              }
            }
            if let caption = currentVideoInfo.caption {
              if !caption.isEmpty {
                Text(caption)
                  .allowsTightening(false)
                  .fontSystem(fontDesignSystem: .body2)
                  .foregroundColor(.white)
                  .lineLimit(isExpanded ? nil : 2)
                  .multilineTextAlignment(.leading)
                  .onTapGesture {
                    withAnimation {
                      isExpanded.toggle()
                    }
                  }
              }
            }
            Label(LocalizedStringKey(stringLiteral: currentVideoInfo.musicTitle ?? "원본 오디오"), systemImage: "music.note")
              .fontSystem(fontDesignSystem: .body2)
              .foregroundColor(.white)
              .padding(.top, 4)
          }
          .padding(.bottom, 4)
          .padding(.leading, 4)
          Spacer()

          // MARK: - Action Buttons

          VStack(spacing: 26) {
            Spacer()
            Button {
              whistleAction()
              let currentContent = apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex]
              apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                let mutableItem = item
                if mutableItem.contentId == currentContent.contentId ?? 0 {
                  mutableItem.whistleCount = currentContent.whistleCount
                  mutableItem.isWhistled = currentContent.isWhistled
                }
                return mutableItem
              }
            } label: {
              ContentLayerButton(
                type: .whistle(currentVideoInfo.whistleCount),
                isFilled: $currentVideoInfo.isWhistled)
            }
            Button {
              currentVideoInfo.isBookmarked.toggle()
              toastViewModel.cancelToastInit(
                message: ToastMessages().bookmarkDeleted,
                undoAction: {
                  feedPlayersViewModel.currentPlayer?.seek(to: .zero)
                  feedPlayersViewModel.currentPlayer?.play()
                  currentVideoInfo.isBookmarked.toggle()
                }) {
                  Task {
                    let currentContent = apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex]
                    _ = await apiViewModel.bookmarkAction(contentID: currentContent.contentId ?? 0, method: .delete)
                    feedPlayersViewModel.removePlayer {
                      index -= 1
                      apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                        let mutableItem = item
                        if mutableItem.contentId == currentContent.contentId ?? 0 {
                          mutableItem.isBookmarked = false
                        }
                        return mutableItem
                      }
                    }
                    apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                      let mutableItem = item
                      if mutableItem.contentId == currentContent.contentId ?? 0 {
                        mutableItem.isBookmarked = currentContent.isBookmarked
                      }
                      return mutableItem
                    }
                  }
                }
            } label: {
              ContentLayerButton(
                type: .bookmark,
                isFilled: $currentVideoInfo.isBookmarked)
            }
            Button {
              let shareURL = URL(string: "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)")!
              let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
              UIApplication.shared.windows.first?.rootViewController?.present(
                activityViewController,
                animated: true,
                completion: nil)
            } label: {
              ContentLayerButton(type: .share)
            }
            Button {
              feedMoreModel.bottomSheetPosition = .absolute(186)
            } label: {
              ContentLayerButton(type: .more)
            }
          }
          .foregroundColor(.Gray10)
        }
      }
      .padding(.bottom, UIScreen.getHeight(102))
      .padding(.horizontal, UIScreen.getWidth(16))
    }
  }
}
