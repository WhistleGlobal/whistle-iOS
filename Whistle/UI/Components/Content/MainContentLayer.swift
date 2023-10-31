//
//  MainContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - MainContentLayer

struct MainContentLayer: View {

  @StateObject var currentVideoInfo: MainContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MainFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @Binding var showDialog: Bool
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
                    toastViewModel.toastInit(message: "\(currentVideoInfo.userName ?? "")님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followAction(userID: currentVideoInfo.userId ?? 0, method: .post)
                    toastViewModel.toastInit(message: "\(currentVideoInfo.userName ?? "")님을 팔로우 중")
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
                Text(currentVideoInfo.isFollowed ? "팔로잉" : "팔로우")
                  .fontSystem(fontDesignSystem: .caption_KO_Semibold)
                  .foregroundColor(.Gray10)
                  .background {
                    Capsule()
                      .stroke(Color.Gray10, lineWidth: 1)
                      .frame(width: 58, height: 26)
                  }
                  .frame(width: 58, height: 26)
              }
            }
          }
          if (currentVideoInfo.caption?.isEmpty) != nil {
            HStack(spacing: 0) {
              Text(currentVideoInfo.caption ?? "")
                .fontSystem(fontDesignSystem: .body2_KO)
                .foregroundColor(.white)
            }
          }
          Label(currentVideoInfo.musicTitle ?? "원본 오디오", systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
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
            VStack(spacing: 2) {
              Image(systemName: currentVideoInfo.isWhistled ? "heart.fill" : "heart")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("\(currentVideoInfo.whistleCount)")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            Task {
              let currentContent = apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex]
              if currentContent.isBookmarked {
                _ = await apiViewModel.bookmarkAction(
                  contentID: currentContent.contentId ?? 0,
                  method: .delete)
                toastViewModel.toastInit(message: "저장 취소했습니다.")
                currentContent.isBookmarked = false
              } else {
                _ = await apiViewModel.bookmarkAction(
                  contentID: currentContent.contentId ?? 0,
                  method: .post)
                toastViewModel.toastInit(message: "저장했습니다.")
                currentContent.isBookmarked = true
              }
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: currentVideoInfo.isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("저장")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            toastViewModel.toastInit(message: "클립보드에 복사되었습니다")
            UIPasteboard.general.setValue(
              "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("공유")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            showDialog = true
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "ellipsis")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("더보기")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
        }
        .foregroundColor(.Gray10)
      }
    }
    .padding(.bottom, UIScreen.getHeight(102))
    .padding(.horizontal, UIScreen.getWidth(16))
  }
}
