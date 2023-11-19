//
//  ContentLayer.swift
//  Whistle
//
//  Created by 박상원 on 11/11/23.
//

import AVFoundation
import BottomSheet
import SwiftUI

// MARK: - ContentLayer

struct ContentLayer<
  A: ObservableObject & Hashable & Decodable,
  T: ObservableObject,
  C: ObservableObject,
  G: ObservableObject
>: View {
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject var currentVideoInfo: A
  @StateObject var feedMoreModel: T
  @StateObject var feedPlayersViewModel: C
  var feedArray: [G]
  let whistleAction: () -> Void
  var dismissAction: DismissAction? = nil
  @State var isExpanded = false
  @State var whistleCount = 0
  @State var profileImg = ""
  @State var username = ""
  @State var isFollowed = false
  @State var isWhistled = false
  @State var isBookmarked = false
  @State var caption = ""
  @State var musicTitle = ""
  var index: Binding<Int>?

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
          VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
              Button {
                navigateToProfile()
              } label: {
                Group {
                  profileImageView(url: profileImg, size: 36)
                    .padding(.trailing, UIScreen.getWidth(4))
                  Text(username)
                    .foregroundColor(.white)
                    .fontSystem(fontDesignSystem: .subtitle1)
                    .padding(.trailing, 16)
                }
              }
              if username != apiViewModel.myProfile.userName {
                Button {
                  follow()
                } label: {
                  Text(isFollowed ? CommonWords().following : CommonWords().follow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                    .fontSystem(fontDesignSystem: .caption_SemiBold)
                    .foregroundColor(Color.LabelColor_Primary_Dark)
                    .background {
                      Capsule()
                        .stroke(Color.LabelColor_Primary_Dark, lineWidth: 1)
                    }
                }
              }
            }
            .padding(.bottom, 12)
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
                .padding(.bottom, 12)
            }
            HStack(spacing: 8) {
              Image(systemName: "music.note")
                .font(.system(size: 16))
              Text(LocalizedStringKey(stringLiteral: musicTitle))
                .fontSystem(fontDesignSystem: .body2)
            }
            .padding(.leading, 2)
            .foregroundColor(.white)
          }
          .padding(.leading, 2)
          Spacer()

          // MARK: - Action Buttons

          VStack(spacing: 26) {
            Spacer()
            Button {
              whistle()
            } label: {
              ContentLayerButton(
                type: .whistle(whistleCount),
                isFilled: $isWhistled)
            }
            .buttonStyle(PressEffectButtonStyle())
            Button {
              bookmark()
            } label: {
              ContentLayerButton(
                type: .bookmark,
                isFilled: $isBookmarked)
            }
            .buttonStyle(PressEffectButtonStyle())
            Button {
              showShareSheet()
            } label: {
              ContentLayerButton(type: .share)
            }
            .buttonStyle(PressEffectButtonStyle())
            Button {
              moreButtonAction()
            } label: {
              ContentLayerButton(type: .more)
            }
            .buttonStyle(PressEffectButtonStyle())
          }
          .foregroundColor(.Gray10)
          .padding(.bottom, UIScreen.getHeight(2))
        }
      }
      .onAppear {
        getContentInfo()
      }
      .padding(.bottom, UIScreen.getHeight(100))
      .padding(.horizontal, UIScreen.getWidth(16))
    }
  }

  func follow() {
    Task {
      guard var currentVideoInfo = currentVideoInfo as? ContentInfo else {
        return
      }

      if isFollowed {
        await apiViewModel.followAction(userID: currentVideoInfo.userId ?? 0, method: .delete)
        toastViewModel.toastInit(message: "\(username)님을 팔로우 취소했습니다")
      } else {
        await apiViewModel.followAction(userID: currentVideoInfo.userId ?? 0, method: .post)
        toastViewModel.toastInit(message: "\(username)님을 팔로우 중입니다")
      }
      currentVideoInfo.isFollowed.toggle()
      isFollowed = currentVideoInfo.isFollowed

      apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
        let mutableItem = item
        if mutableItem.userId == currentVideoInfo.userId {
          mutableItem.isFollowed = isFollowed
        }
        return mutableItem
      }
    }
  }

  func showShareSheet() {
    guard let currentVideoInfo = currentVideoInfo as? ContentInfo else {
      return
    }
    let shareURL = URL(string: "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)")!
    let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(
      activityViewController,
      animated: true,
      completion: nil)
  }

  func navigateToProfile() {
    guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
      return
    }
    guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
      return
    }

    if feedMoreModel is MainFeedMoreModel || feedMoreModel is BookmarkedFeedMoreModel {
      feedMoreModel.isRootStacked = true
    }
    playersViewModel.stopPlayer()
    if playersViewModel is MemeberPlayersViewModel || playersViewModel is MyFeedPlayersViewModel {
      dismissAction?()
    }
  }

  func moreButtonAction() {
    guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
      return
    }

    if let feedMoreModel = feedMoreModel as? MyFeedMoreModel {
      feedMoreModel.bottomSheetPosition = .absolute(186)
    } else {
      feedMoreModel.bottomSheetPosition = .absolute(242)
    }
  }

  func whistle() {
    whistleAction()
    guard let currentVideoInfo = currentVideoInfo as? ContentInfo else {
      return
    }
    guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
      return
    }
    isWhistled = currentVideoInfo.isWhistled
    whistleCount = currentVideoInfo.whistleCount

    guard let currentContent = feedArray[playersViewModel.currentVideoIndex] as? ContentInfo else { return }
    apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
      let mutableItem = item
      if mutableItem.contentId == currentContent.contentId {
        mutableItem.whistleCount = currentContent.whistleCount
        mutableItem.isWhistled = isWhistled
      }
      return mutableItem
    }
  }

  func bookmark() {
    guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
      return
    }
    guard var currentContent = feedArray[playersViewModel.currentVideoIndex] as? ContentInfo else { return }
    Task {
      if currentContent.isBookmarked {
        currentContent.isBookmarked.toggle()
        isBookmarked = currentContent.isBookmarked
        _ = await apiViewModel.bookmarkAction(
          contentID: currentContent.contentId ?? 0,
          method: .delete)
        toastViewModel.toastInit(message: ToastMessages().bookmarkDeleted)
      } else {
        currentContent.isBookmarked.toggle()
        isBookmarked = currentContent.isBookmarked
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
  }

  func getContentInfo() {
    guard let info = currentVideoInfo as? ContentInfo else {
      return
    }

    let commonInfo: [ContentInfo] = [info]

    for contentInfo in commonInfo {
      whistleCount = contentInfo.whistleCount
      profileImg = contentInfo.profileImg ?? ""
      username = contentInfo.userName ?? ""
      isFollowed = contentInfo.isFollowed
      isWhistled = contentInfo.isWhistled
      isBookmarked = contentInfo.isBookmarked
      caption = contentInfo.caption ?? ""
      musicTitle = contentInfo.musicTitle ?? "원본 오디오"
    }
  }
}

// MARK: - ContentInfo

protocol ContentInfo {
  var contentId: Int? { get }
  var userId: Int? { get }
  var whistleCount: Int { get set }
  var profileImg: String? { get }
  var userName: String? { get }
  var isFollowed: Bool { get set }
  var isWhistled: Bool { get set }
  var isBookmarked: Bool { get set }
  var caption: String? { get }
  var musicTitle: String? { get }
}

// MARK: - MainContent + ContentInfo

extension MainContent: ContentInfo { }

// MARK: - MemberContent + ContentInfo

extension MemberContent: ContentInfo { }

// MARK: - MyContent + ContentInfo

extension MyContent: ContentInfo { }

// MARK: - Bookmark + ContentInfo

extension Bookmark: ContentInfo { }

// MARK: - FeedMoreModel

protocol FeedMoreModel {
  var showReport: Bool { get set }
  var isRootStacked: Bool { get set }
  var bottomSheetPosition: BottomSheetPosition { get set }
}

// MARK: - MainFeedMoreModel + FeedMoreModel

extension MainFeedMoreModel: FeedMoreModel { }

// MARK: - MemberFeedMoreModel + FeedMoreModel

extension MemberFeedMoreModel: FeedMoreModel { }

// MARK: - MyFeedMoreModel + FeedMoreModel

extension MyFeedMoreModel: FeedMoreModel { }

// MARK: - BookmarkedFeedMoreModel + FeedMoreModel

extension BookmarkedFeedMoreModel: FeedMoreModel { }

// MARK: - PlayersViewModel

protocol PlayersViewModel {
  var prevPlayer: AVPlayer? { get set }
  var currentPlayer: AVPlayer? { get set }
  var nextPlayer: AVPlayer? { get set }
  var currentVideoIndex: Int { get set }
  func stopPlayer()
}

// MARK: - MainFeedPlayersViewModel + PlayersViewModel

extension MainFeedPlayersViewModel: PlayersViewModel { }

// MARK: - MemeberPlayersViewModel + PlayersViewModel

extension MemeberPlayersViewModel: PlayersViewModel { }

// MARK: - MyFeedPlayersViewModel + PlayersViewModel

extension MyFeedPlayersViewModel: PlayersViewModel { }

// MARK: - BookmarkedPlayersViewModel + PlayersViewModel

extension BookmarkedPlayersViewModel: PlayersViewModel { }
