//
//  BookmarkedContentPlayerview.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import _AVKit_SwiftUI
import AVFoundation
import Combine
import Kingfisher
import SwiftUI

// MARK: - BookmarkedContentPlayerview

struct BookmarkedContentPlayerview: View {
  @AppStorage("showGuide") var showGuide = true
  @Environment(\.scenePhase) var scenePhase
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = BookmarkedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = BookmarkedFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var bartintModel = BarTintModel.shared

  @State var newId = UUID()
  @State var timer: Timer? = nil
  @State var viewTimer: Timer? = nil
  @State var showPlayButton = false
  @State var viewCount: ViewCount = .init()
  @State var processedContentId: Set<Int> = []
  @State var isSwipeable = true
  @Binding var currentContentInfo: Bookmark?
  @Binding var index: Int
  @Binding var isChangable: Bool

  let lifecycleDelegate: ViewLifecycleDelegate?
  let dismissAction: DismissAction
  let processor = BlurImageProcessor(blurRadius: 100)

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(apiViewModel.bookmark.enumerated()), id: \.element) { index, content in
        ZStack {
          Color.black.overlay {
            Color.clear.overlay {
              KFImage.url(URL(string: apiViewModel.bookmark[index].thumbnailUrl))
                .cacheMemoryOnly()
                .placeholder {
                  Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .resizable()
                .setProcessor(processor)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            KFImage.url(URL(string: apiViewModel.bookmark[index].thumbnailUrl))
              .cacheMemoryOnly()
              .placeholder {
                Color.black
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .resizable()
              .aspectRatio(
                contentMode: content.aspectRatio ?? 1.0 > Double(15.0 / 9.0)
                  ? .fill
                  : .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let player = feedPlayersViewModel.currentPlayer, index == feedPlayersViewModel.currentVideoIndex {
              ContentPlayer(player: player, aspectRatio: content.aspectRatio)
                .frame(width: UIScreen.width, height: UIScreen.height)
                .onTapGesture(count: 2) {
                  whistleToggle(content: content, index)
                }
                .onAppear {
                  isChangable = false
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isChangable = true
                  }
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
                  feedMoreModel.bottomSheetPosition = .absolute(186)
                }
              playButton(toPlay: player.rate == 0)
                .opacity(showPlayButton ? 1 : 0)
                .allowsHitTesting(false)
            }
            Group {
              ContentGradientLayer()
                .allowsHitTesting(false)
              if !tabbarModel.isCollpased() {
//                    ContentLayer(
//                      currentVideoInfo: content,
//                      feedMoreModel: BookmarkedFeedMoreModel.shared,
//                      feedPlayersViewModel: BookmarkedPlayersViewModel.shared,
//                      feedArray: apiViewModel.bookmark,
//                      whistleAction: { whistleToggle(content: content, index) },
//                      index: $index)
                BookmarkedContentLayer(
                  currentVideoInfo: content,
                  index: $index,
                  whistleAction: {
                    whistleToggle(content: content, index)
                  })
                  .padding(.bottom, UIScreen.main.nativeBounds.height == 1334 ? 24 : 0)
              }
              if feedMoreModel.bottomSheetPosition != .hidden {
                DimsThick()
                  .onAppear {
                    isChangable = false
                    isSwipeable = false
                  }
                  .onDisappear {
                    isChangable = true
                    isSwipeable = true
                  }
              }
            }
            .frame(width: UIScreen.width, height: UIScreen.height)
            if BlockList.shared.userIds.contains(content.userId ?? 0) {
              KFImage.url(URL(string: content.thumbnailUrl))
                .placeholder {
                  Color.black
                }
                .resizable()
                .scaledToFill()
                .blur(radius: 30)
                .overlay {
                  VStack {
                    Image(systemName: "eye.slash.fill")
                      .font(.system(size: 44))
                      .foregroundColor(.Gray10)
                      .padding(.bottom, 26)
                    Text("차단된 계정의 콘텐츠입니다.")
                      .fontSystem(fontDesignSystem: .subtitle1)
                      .foregroundColor(.LabelColor_Primary_Dark)
                      .padding(.bottom, 12)
                    Text("차단된 계정의 모든 콘텐츠는\n회원님의 피드에 노출되지 않습니다.")
                      .multilineTextAlignment(.center)
                      .fontSystem(fontDesignSystem: .body2)
                      .foregroundColor(.LabelColor_Secondary_Dark)
                  }
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
    .toolbar(!isSwipeable ? .hidden : .visible, for: .navigationBar)
    .toolbarRole(.editor)
    .onAppear {
      bartintModel.tintColor = .white
      if index == 0 {
        lifecycleDelegate?.onAppear()
      } else {
        lifecycleDelegate?.onAppear()
        feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        feedPlayersViewModel.currentPlayer?.play()
      }
    }
    .onDisappear {
      bartintModel.tintColor = .labelColorPrimary
      lifecycleDelegate?.onDisappear()
      feedPlayersViewModel.stopPlayer()
    }
    .ignoresSafeArea()
    .onChange(of: tabbarModel.tabSelection) { newValue in
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

extension BookmarkedContentPlayerview {
  func whistleToggle(content: Bookmark, _ index: Int) {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.bookmark[index].isWhistled {
//      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      Task {
        await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .delete)
//        }
      }
      apiViewModel.bookmark[index].whistleCount -= 1
    } else {
//      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      Task {
        await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .post)
//        }
      }
      apiViewModel.bookmark[index].whistleCount += 1
    }
    apiViewModel.bookmark[index].isWhistled.toggle()
    currentContentInfo = apiViewModel.bookmark[index]
  }
}
