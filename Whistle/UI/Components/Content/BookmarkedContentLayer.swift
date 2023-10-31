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
  @Binding var index: Int
  var whistleAction: () -> Void
  let dismissAction: DismissAction

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button {
          dismissAction()
        } label: {
          Image(systemName: "chevron.backward")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.trailing, 16)
        }
        Spacer()
      }
      .padding(.top, 38)
      Spacer()
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            if currentVideoInfo.userName != apiViewModel.myProfile.userName {
              Button {
                feedMoreModel.isRootStacked = true
              } label: {
                Group {
                  profileImageView(url: currentVideoInfo.profileImg, size: 36)
                    .padding(.trailing, UIScreen.getWidth(8))
                  Text(currentVideoInfo.userName)
                    .foregroundColor(.white)
                    .fontSystem(fontDesignSystem: .subtitle1)
                    .padding(.trailing, 16)
                }
              }
            } else {
              Group {
                profileImageView(url: currentVideoInfo.profileImg, size: 36)
                  .padding(.trailing, 12)
                Text(currentVideoInfo.userName)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .subtitle1)
                  .padding(.trailing, 16)
              }
            }
            if currentVideoInfo.userName != apiViewModel.myProfile.userName {
              Button {
                Task {
                  if currentVideoInfo.isFollowed {
                    await apiViewModel.followAction(userID: currentVideoInfo.userId, method: .delete)
                    toastViewModel.toastInit(message: "\(currentVideoInfo.userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followAction(userID: currentVideoInfo.userId, method: .post)
                    toastViewModel.toastInit(message: "\(currentVideoInfo.userName)님을 팔로우 중")
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
            let currentContent = apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex]
            apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
              let mutableItem = item
              if mutableItem.contentId == currentContent.contentId {
                if mutableItem.isWhistled {
                  mutableItem.whistleCount -= 1
                } else {
                  mutableItem.whistleCount += 1
                }
                mutableItem.isWhistled.toggle()
              }
              return mutableItem
            }
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
            toastViewModel.cancelToastInit(message: "저장 취소되었습니다.") {
              Task {
                let currentContent = apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex]
                _ = await apiViewModel.bookmarkAction(contentID: currentContent.contentId, method: .delete)
                feedPlayersViewModel.removePlayer {
                  index -= 1
                  apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                    let mutableItem = item
                    if mutableItem.contentId == currentContent.contentId {
                      mutableItem.isBookmarked = false
                    }
                    return mutableItem
                  }
                }
              }
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "bookmark.fill")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("저장")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            let shareURL = URL(string: "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)")!
            let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(
              activityViewController,
              animated: true,
              completion: nil)
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
//            showDialog = true
            feedMoreModel.bottomSheetPotision = .absolute(186)
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
