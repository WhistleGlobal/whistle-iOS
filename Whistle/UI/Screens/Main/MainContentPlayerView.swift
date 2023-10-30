//
//  MainContentPlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import _AVKit_SwiftUI
import AVFoundation
import Combine
import Kingfisher
import SwiftUI

// MARK: - MainContentPlayerView

struct MainContentPlayerView: View {
  @AppStorage("showGuide") var showGuide = true
  @Environment(\.scenePhase) var scenePhase
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = FeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = FeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared

  @State var newId = UUID()
  @State var timer: Timer? = nil
  @State var viewTimer: Timer? = nil
  @State var showPlayButton = false
  @State var viewCount: ViewCount = .init()
  @State var processedContentId: Set<Int> = []
  @Binding var currentContentInfo: MainContent?
  @Binding var index: Int
  let lifecycleDelegate: ViewLifecycleDelegate?

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(apiViewModel.mainFeed.enumerated()), id: \.element) { index, content in
        ZStack {
          Color.clear.overlay {
            if let url = apiViewModel.mainFeed[index].thumbnailUrl {
              KFImage.url(URL(string: url))
                .placeholder {
                  Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let player = feedPlayersViewModel.currentPlayer, index == feedPlayersViewModel.currentVideoIndex {
              ContentPlayer(player: player)
                .frame(width: UIScreen.width, height: UIScreen.height)
                .onTapGesture(count: 2) {
                  whistleToggle(content: content, index)
                }
                .onAppear {
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  let dateString = dateFormatter.string(from: .now)
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    viewCount.views[index].viewDate = dateString
                  } else {
                    viewCount.views.append(.init(contentId: content.contentId ?? 0, viewDate: dateString))
                  }
                }
                .onDisappear {
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    let viewDate = viewCount.views[index].viewDate.toDate()
                    var nowDate = Date.now
                    nowDate.addTimeInterval(3600 * 9)
                    let viewTime = nowDate.timeIntervalSince(viewDate ?? Date.now)
                    viewCount.views[index].viewTime = "\(Int(viewTime))"
                  }
                }
                .onTapGesture {
                  if player.rate == 0.0 {
                    player.play()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  } else {
                    player.pause()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  }
                }
                .onLongPressGesture {
                  HapticManager.instance.impact(style: .medium)
                  feedMoreModel.showDialog = true
                }
                .overlay {
                  if tabbarModel.tabWidth != 56 {
                    MainContentLayer(
                      currentVideoInfo: content,
                      showDialog: $feedMoreModel.showDialog,
                      whistleAction: {
                        whistleToggle(content: content, index)
                      })
                  }
                }
              playButton(toPlay: player.rate == 0)
                .opacity(showPlayButton ? 1 : 0)
                .allowsHitTesting(false)
            }
            if showGuide {
              VStack {
                Spacer()
                Button {
                  showGuide = false
                } label: {
                  Text("닫기")
                    .fontSystem(fontDesignSystem: .subtitle2_KO)
                    .foregroundColor(Color.LabelColor_Primary_Dark)
                    .frame(width: UIScreen.width - 32, height: 56)
                    .background {
                      glassMorphicView(cornerRadius: 12)
                        .overlay {
                          RoundedRectangle(cornerRadius: 12)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(
                              LinearGradient.Border_Glass)
                        }
                    }
                }
                .padding(.bottom, 32)
              }
              .frame(width: UIScreen.width, height: UIScreen.height)
              .ignoresSafeArea()
              .ignoresSafeArea(.all, edges: .top)
              .background {
                Color.clear.overlay {
                  Image("gestureGuide")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .ignoresSafeArea(.all, edges: .top)
                }
                .ignoresSafeArea()
                .ignoresSafeArea(.all, edges: .top)
              }
            }
          }

          .ignoresSafeArea()
        }
        .frame(width: UIScreen.width, height: UIScreen.height)
        .ignoresSafeArea()
        .onReceive(apiViewModel.publisher) { id in
          newId = id
        }
        .id(newId)
      }
    }
    .onAppear {
      if index == 0 {
        lifecycleDelegate?.onAppear()
      } else {
        feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        feedPlayersViewModel.currentPlayer?.play()
      }
    }
    .onDisappear {
      lifecycleDelegate?.onDisappear()
    }
    .ignoresSafeArea()
    .onAppear {
      WhistleLogger.logger.notice("MainContentPlayerView onAppear")
    }
    .onChange(of: tabbarModel.tabSelectionNoAnimation) { newValue in
      if newValue == .main {
        feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        feedPlayersViewModel.currentPlayer?.play()
        return
      }
      feedPlayersViewModel.stopPlayer()
      apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
        var tempSet: Set<Int> = []
        for view in viewCountList {
          tempSet.insert(view.contentId)
        }
        processedContentId = processedContentId.union(tempSet)
      }
    }
    .onChange(of: scenePhase) { newValue in
      switch newValue {
      case .background:
        apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
          var tempSet: Set<Int> = []
          for view in viewCountList {
            tempSet.insert(view.contentId)
          }
          processedContentId = processedContentId.union(tempSet)
        }
      default:
        break
      }
    }
  }

}

// MARK: - ViewLifecycleDelegate

protocol ViewLifecycleDelegate {
  func onAppear()
  func onDisappear()
}

// MARK: - MainContentLayer

struct MainContentLayer: View {

  @StateObject var currentVideoInfo: MainContent = .init()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = FeedMoreModel.shared
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
        VStack(spacing: 28) {
          Spacer()
          Button {
            whistleAction()
          } label: {
            VStack(spacing: 0) {
              Image(systemName: currentVideoInfo.isWhistled ? "heart.fill" : "heart")
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .frame(width: 36, height: 36)
              Text("\(currentVideoInfo.whistleCount)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .subtitle3_KO)
            }
            .padding(.bottom, -4)
          }
          Button {
            toastViewModel.toastInit(message: "클립보드에 복사되었어요")
            UIPasteboard.general.setValue(
              "https://readywhistle.com/content_uni?contentId=\(currentVideoInfo.contentId ?? 0)",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
          Button {
            showDialog = true
            print("showDialog: \(showDialog)")
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
        }
      }
    }
//    .padding(.bottom, UIScreen.getHeight(48))a
    .padding(.bottom, UIScreen.getHeight(100))
    .padding(.trailing, UIScreen.getWidth(12))
    .padding(.leading, UIScreen.getWidth(16))
  }
}

extension MainContentPlayerView {
  func whistleToggle(content: MainContent, _ index: Int) {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.mainFeed[index].isWhistled {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .delete)
        }
      }
      apiViewModel.mainFeed[index].whistleCount -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .post)
        }
      }
      apiViewModel.mainFeed[index].whistleCount += 1
    }
    apiViewModel.mainFeed[index].isWhistled.toggle()
  }
}
