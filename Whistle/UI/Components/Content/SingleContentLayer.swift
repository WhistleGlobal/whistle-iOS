//
//  SingleContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 11/6/23.
//

import BottomSheet
import Foundation
import SwiftUI

// MARK: - MainContentLayer

struct SingleContentLayer: View {

  @StateObject var currentVideoInfo: MainContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @State var timer: Timer? = nil
  @State var isExpanded = false
  @Binding var bottomSheetPosition: BottomSheetPosition

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
              HapticManager.instance.impact(style: .medium)
              timer?.invalidate()
              if apiViewModel.singleContent.isWhistled {
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                  Task {
                    await apiViewModel.whistleAction(contentID: currentVideoInfo.contentId ?? 0, method: .delete)
                  }
                }
                apiViewModel.singleContent.whistleCount -= 1
              } else {
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                  Task {
                    await apiViewModel.whistleAction(contentID: currentVideoInfo.contentId ?? 0, method: .post)
                  }
                }
                apiViewModel.singleContent.whistleCount += 1
              }
              apiViewModel.singleContent.isWhistled.toggle()
            } label: {
              ContentLayerButton(
                isFilled: $currentVideoInfo.isWhistled,
                image: "heart",
                filledImage: "heart.fill",
                label: "\(currentVideoInfo.whistleCount)")
            }
            Button {
              Task {
                if currentVideoInfo.isBookmarked {
                  currentVideoInfo.isBookmarked.toggle()
                  _ = await apiViewModel.bookmarkAction(
                    contentID: currentVideoInfo.contentId ?? 0,
                    method: .delete)
                  toastViewModel.toastInit(message: ToastMessages().bookmarkDeleted)
                } else {
                  currentVideoInfo.isBookmarked.toggle()
                  _ = await apiViewModel.bookmarkAction(
                    contentID: currentVideoInfo.contentId ?? 0,
                    method: .post)
                  toastViewModel.toastInit(message: ToastMessages().bookmark)
                }
                await apiViewModel.requestMyBookmark()
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
              bottomSheetPosition = .absolute(186)
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
}

