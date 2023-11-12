//
//  MemberContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 10/31/23.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - MemberContentLayer

struct MemberContentLayer: View {
  @StateObject var currentVideoInfo: MemberContent
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MemberFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = MemeberPlayersViewModel.shared
  @State var isExpanded = false
  var whistleAction: () -> Void
  let dismissAction: DismissAction

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
              if currentVideoInfo.userName ?? "" != apiViewModel.myProfile.userName {
                Button {
                  feedPlayersViewModel.stopPlayer()
                  dismissAction()
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
                      if mutableItem.userId == currentVideoInfo.userId {
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
              let currentContent = apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex]
              apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                let mutableItem = item
                if mutableItem.contentId == currentContent.contentId {
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
              Task {
                let currentContent = apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex]
                if currentContent.isBookmarked {
                  currentContent.isBookmarked.toggle()
                  _ = await apiViewModel.bookmarkAction(
                    contentID: currentContent.contentId ?? 0,
                    method: .delete)
                  toastViewModel.toastInit(message: ToastMessages().bookmarkDeleted)
                } else {
                  currentContent.isBookmarked.toggle()
                  _ = await apiViewModel.bookmarkAction(
                    contentID: currentContent.contentId ?? 0,
                    method: .post)
                  toastViewModel.toastInit(message: ToastMessages().bookmark)
                }
                await apiViewModel.requestMyBookmark()
                apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                  let mutableItem = item
                  if mutableItem.contentId == currentContent.contentId {
                    mutableItem.isBookmarked = currentContent.isBookmarked
                  }
                  return mutableItem
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
              feedMoreModel.bottomSheetPosition = .absolute(242)
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
