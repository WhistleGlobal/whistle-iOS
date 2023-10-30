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
  @Binding var showDialog: Bool
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
              Text("\(currentVideoInfo.contentWhistleCount ?? 0)")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
//          Button {
//            Task {
//              let currentContent = apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex]
//              if currentContent.isBookmarked {
//                _ = await apiViewModel.bookmarkAction(
//                  contentID: currentContent.contentId ?? 0,
//                  method: .delete)
//                toastViewModel.toastInit(message: "저장 취소했습니다.")
//                currentContent.isBookmarked = false
//              } else {
//                _ = await apiViewModel.bookmarkAction(
//                  contentID: currentContent.contentId ?? 0,
//                  method: .post)
//                toastViewModel.toastInit(message: "저장했습니다.")
//                currentContent.isBookmarked = true
//              }
//            }
//          } label: {
//            VStack(spacing: 2) {
//              Image(systemName: currentVideoInfo.isBookmarked ? "bookmark.fill" : "bookmark")
//                .font(.system(size: 26))
//                .frame(width: 36, height: 36)
//              Text("저장")
//                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
//            }
//            .frame(height: UIScreen.getHeight(56))
//          }
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
