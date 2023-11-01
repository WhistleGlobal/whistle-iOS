//
//  MyContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - MyContentLayer

struct MyContentLayer: View {

  @StateObject var currentVideoInfo: MyContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MyFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = MyFeedPlayersViewModel.shared
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
            Group {
              profileImageView(url: currentVideoInfo.profileImg, size: 36)
                .padding(.trailing, 12)
              Text(currentVideoInfo.userName ?? "")
                .foregroundColor(.white)
                .fontSystem(fontDesignSystem: .subtitle1)
                .padding(.trailing, 16)
            }
          }
          if let caption = currentVideoInfo.caption {
            if !caption.isEmpty {
              HStack(spacing: 0) {
                Text(currentVideoInfo.caption ?? "")
                  .fontSystem(fontDesignSystem: .body2_KO)
                  .foregroundColor(.white)
              }
            }
          }
          Label(LocalizedStringKey(stringLiteral: currentVideoInfo.musicTitle ?? "원본 오디오"), systemImage: "music.note")
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
                mutableItem.whistleCount = currentContent.whistleCount ?? 0
                mutableItem.isWhistled = currentContent.isWhistled
              }
              return mutableItem
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: currentVideoInfo.isWhistled ? "heart.fill" : "heart")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("\(currentVideoInfo.whistleCount ?? 0)")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            Task {
              let currentContent = apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex]
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
              apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                let mutableItem = item
                if mutableItem.contentId == currentContent.contentId {
                  mutableItem.isBookmarked = currentContent.isBookmarked
                }
                return mutableItem
              }
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: currentVideoInfo.isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().save)
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
              Text(CommonWords().share)
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            feedMoreModel.bottomSheetPosition = .absolute(186)
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "ellipsis")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().more)
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
