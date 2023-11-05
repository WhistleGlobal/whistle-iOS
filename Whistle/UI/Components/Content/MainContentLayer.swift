//
//  MainContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit

// MARK: - MainContentLayer

struct MainContentLayer: View {

  @StateObject var currentVideoInfo: MainContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MainFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  var whistleAction: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            if currentVideoInfo.userName ?? "" != apiViewModel.myProfile.userName {
              Button {
                feedMoreModel.isRootStacked = true
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
              HStack(spacing: 0) {
                Text(currentVideoInfo.caption ?? "")
                  .fontSystem(fontDesignSystem: .body2)
                  .foregroundColor(.white)
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
          } label: {
            ContentLayerButton(
              isFilled: $currentVideoInfo.isWhistled,
              image: "heart",
              filledImage: "heart.fill",
              label: "\(currentVideoInfo.whistleCount)")
          }
          Button {
            Task {
              let currentContent = apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex]
              if currentContent.isBookmarked {
                _ = await apiViewModel.bookmarkAction(
                  contentID: currentContent.contentId ?? 0,
                  method: .delete)
                toastViewModel.toastInit(message: ToastMessages().bookmarkDeleted)
                currentContent.isBookmarked = false
              } else {
                _ = await apiViewModel.bookmarkAction(
                  contentID: currentContent.contentId ?? 0,
                  method: .post)
                toastViewModel.toastInit(message: ToastMessages().bookmark)
                currentContent.isBookmarked = true
              }
            }
          } label: {
            ContentLayerButton(
              isFilled: $currentVideoInfo.isBookmarked,
              image: "bookmark",
              filledImage: "bookmark.fill",
              label: CommonWords().bookmark)
          }
          Button {
            let shareURL = URL(
              string: "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)")!
            let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(
              activityViewController,
              animated: true,
              completion: nil)
          } label: {
            ContentLayerButton(image: "square.and.arrow.up", label: CommonWords().share)
          }
          Button {
            feedMoreModel.bottomSheetPosition = .absolute(242)
          } label: {
            ContentLayerButton(image: "ellipsis", label: CommonWords().more)
          }
        }
        .foregroundColor(.Gray10)
      }
    }
    .padding(.bottom, UIScreen.getHeight(102))
    .padding(.horizontal, UIScreen.getWidth(16))
  }
}
