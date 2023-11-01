//
//  GuestContentLayer.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit

// MARK: - GuestContentLayer

struct GuestContentLayer: View {

  @StateObject var currentVideoInfo: GuestContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = GuestMainFeedMoreModel.shared
  @StateObject var feedPlayersViewModel = GuestFeedPlayersViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            if currentVideoInfo.userName ?? "" != apiViewModel.myProfile.userName {
              Button {
                feedMoreModel.bottomSheetPosition = .dynamic
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
                feedMoreModel.bottomSheetPosition = .dynamic
              } label: {
                Text(CommonWords().follow)
                  .fontSystem(fontDesignSystem: .caption_SemiBold)
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
            feedMoreModel.bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "heart")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("\(currentVideoInfo.whistleCount ?? 0)")
                .fontSystem(fontDesignSystem: .caption_SemiBold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            feedMoreModel.bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "bookmark")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().bookmark)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
            }
            .frame(height: UIScreen.getHeight(56))
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
            VStack(spacing: 2) {
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().share)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            feedMoreModel.bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "ellipsis")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().more)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
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
