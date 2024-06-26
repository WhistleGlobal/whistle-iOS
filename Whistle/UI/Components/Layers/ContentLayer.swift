//
//  ContentLayer.swift
//  Whistle
//
//  Created by 박상원 on 11/11/23.
//

import AVFoundation
import BottomSheet
import SwiftUI
import TagKit

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
  @State var userId = 0
  @State var whistleCount = 0
  @State var profileImg = ""
  @State var username = ""
  @State var isFollowed = false
  @State var isWhistled = false
  @State var isBookmarked = false
  @State var showSafariView = false
  @State var caption = ""
  @State var hashtags: [String] = []
  @State var musicTitle = ""
  @State var sourceURL = ""
  @Binding var refreshToken: Bool
  var index: Int? = nil

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
              userNameAndProfile
//              Button {
//                navigateToProfile()
//              } label: {
//                Group {
//                  profileImageView(url: profileImg, size: 36)
//                    .padding(.trailing, UIScreen.getWidth(4))
//                  Text(username)
//                    .foregroundColor(.white)
//                    .fontSystem(fontDesignSystem: .subtitle1)
//                    .padding(.trailing, 16)
//                }
//              }
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
            }
            TagList(tags: hashtags, horizontalSpacing: 0, verticalSpacing: 0) { tag in
              NavigationLink {
                TagResultView(tagText: tag)
              } label: {
                Text("#\(tag)  ")
                  .fontSystem(fontDesignSystem: .subtitle3)
                  .foregroundColor(.LabelColor_Primary_Dark)
              }
              .id(UUID())
            }
            .padding(.bottom, 8)
            HStack(spacing: 12) {
              HStack(spacing: 8) {
                Image(systemName: "music.note")
                  .font(.system(size: 16))
                Text(LocalizedStringKey(stringLiteral: musicTitle))
                  .fontSystem(fontDesignSystem: .body2)
              }
              if !sourceURL.isEmpty {
                HStack(spacing: 8) {
                  Image(systemName: "link")
                    .font(.system(size: 16, weight: .semibold))
                  Text(LocalizedStringKey(stringLiteral: "영상 출처"))
                    .fontSystem(fontDesignSystem: .subtitle3)
                }
                .onTapGesture {
                  showBrowser()
                }
              }
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
    .sheet(isPresented: $showSafariView, onDismiss: { resumePlayer() }) {
      SafariView(url: URL(string: sourceURL)!)
        .ignoresSafeArea()
    }
    .onChange(of: refreshToken) { _ in
      WhistleLogger.logger.debug("refreshToken: \(refreshToken)")
      guard let currentVideoInfo = currentVideoInfo as? ContentInfo else {
        return
      }
      guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
        return
      }
      isWhistled = currentVideoInfo.isWhistled
      whistleCount = currentVideoInfo.whistleCount

      guard let currentContent = feedArray[playersViewModel.currentVideoIndex] as? ContentInfo else { return }
      if feedMoreModel is MainFeedMoreModel {
      } else {
        apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
          let mutableItem = item
          if mutableItem.contentId == currentContent.contentId {
            mutableItem.whistleCount = currentContent.whistleCount
            mutableItem.isWhistled = isWhistled
          }
          return mutableItem
        }
      }
    }
  }

  func follow() {
    Task {
      guard var currentVideoInfo = currentVideoInfo as? ContentInfo else {
        return
      }
      guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
        return
      }

      if type(of: feedMoreModel) == GuestMainFeedMoreModel.self {
        feedMoreModel.bottomSheetPosition = .dynamic
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

  func showBrowser() {
    guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
      return
    }
    playersViewModel.stopPlayer()
    showSafariView = true
  }

  func resumePlayer() {
    guard let playersViewModel = feedPlayersViewModel as? PlayersViewModel else {
      return
    }
    playersViewModel.currentPlayer?.play()
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

    if type(of: feedMoreModel) == GuestMainFeedMoreModel.self {
      feedMoreModel.bottomSheetPosition = .dynamic
      return
    }

    if feedMoreModel is MainFeedMoreModel || feedMoreModel is BookmarkedFeedMoreModel {
      feedMoreModel.isRootStacked = true
    }
    playersViewModel.stopPlayer()
    if playersViewModel is MemberContentViewModel || playersViewModel is MyFeedPlayersViewModel {
      dismissAction?()
    }
  }

  func moreButtonAction() {
    guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
      return
    }

    if let feedMoreModel = feedMoreModel as? MyFeedMoreModel {
      feedMoreModel.bottomSheetPosition = .absolute(186)
    } else if type(of: feedMoreModel) == GuestMainFeedMoreModel.self {
      feedMoreModel.bottomSheetPosition = .dynamic
    } else {
      feedMoreModel.bottomSheetPosition = .absolute(242)
    }
  }

  func whistle() {
    whistleAction()

    guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
      return
    }

    if type(of: feedMoreModel) == GuestMainFeedMoreModel.self {
      feedMoreModel.bottomSheetPosition = .dynamic
      return
    }

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
    guard var feedMoreModel = feedMoreModel as? FeedMoreModel else {
      return
    }
    if type(of: feedMoreModel) == GuestMainFeedMoreModel.self {
      feedMoreModel.bottomSheetPosition = .dynamic
      return
    }
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
      userId = contentInfo.userId ?? 0
      profileImg = contentInfo.profileImg ?? ""
      username = contentInfo.userName ?? ""
      isFollowed = contentInfo.isFollowed
      isWhistled = contentInfo.isWhistled
      isBookmarked = contentInfo.isBookmarked
      caption = contentInfo.caption ?? ""
      sourceURL = contentInfo.sourceURL ?? ""
      hashtags = contentInfo.hashtags ?? []
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
  var sourceURL: String? { get }
  var hashtags: [String]? { get }
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

// MARK: - GuestContent + ContentInfo

extension GuestContent: ContentInfo { }

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

// MARK: - SearchFeedMoreModel + FeedMoreModel

extension SearchFeedMoreModel: FeedMoreModel { }

// MARK: - TagSearchFeedMoreModel + FeedMoreModel

extension TagSearchFeedMoreModel: FeedMoreModel { }

// MARK: - GuestMainFeedMoreModel + FeedMoreModel

extension GuestMainFeedMoreModel: FeedMoreModel { }

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

// MARK: - MyFeedPlayersViewModel + PlayersViewModel

// extension MemeberPlayersViewModel: PlayersViewModel { }

extension MyFeedPlayersViewModel: PlayersViewModel { }

// MARK: - MemberContentViewModel + PlayersViewModel

extension MemberContentViewModel: PlayersViewModel { }

// MARK: - BookmarkedPlayersViewModel + PlayersViewModel

extension BookmarkedPlayersViewModel: PlayersViewModel { }

// MARK: - SearchPlayersViewModel + PlayersViewModel

extension SearchPlayersViewModel: PlayersViewModel { }

// MARK: - TagSearchPlayersViewModel + PlayersViewModel

extension TagSearchPlayersViewModel: PlayersViewModel { }

// MARK: - GuestFeedPlayersViewModel + PlayersViewModel

extension GuestFeedPlayersViewModel: PlayersViewModel { }

// MARK: - MyTeamFeedPlayersViewModel + PlayersViewModel

extension MyTeamFeedPlayersViewModel: PlayersViewModel { }

extension ContentLayer {
  @ViewBuilder
  var userNameAndProfile: some View {
    if
      feedMoreModel is MainFeedMoreModel || feedMoreModel is BookmarkedFeedMoreModel ||
      feedMoreModel is TagSearchFeedMoreModel
    {
      NavigationLink {
        ProfileView(
          profileType: userId == apiViewModel.myProfile.userId ? .my : .member,
          isFirstProfileLoaded: .constant(true),
          userId: userId)
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
      .id(UUID())
    } else {
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
    }
  }
}

// MARK: - PressEffectButtonStyle

struct PressEffectButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
      .opacity(configuration.isPressed ? 0.6 : 1.0)
      .animation(.easeInOut, value: configuration.isPressed)
  }
}
