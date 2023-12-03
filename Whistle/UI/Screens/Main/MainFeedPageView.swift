//
//  MainFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import Mixpanel
import SwiftUI

// MARK: - MainFeedPageView

struct MainFeedPageView: UIViewRepresentable {
  @ObservedObject var refreshableModel = MainRefreshableModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @StateObject var mainFeedTabModel = MainFeedTabModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @State var timer: Timer?
  @State var currentContentInfo: MainContent?
  @State var isChangable = true
  @Binding var viewDuration: String
  @Binding var viewedContenId: Set<Int>
  @Binding var scrolledContentCount: Int
  @Binding var index: Int

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MainContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
        isChangable: $isChangable,
        lifecycleDelegate: context.coordinator))

    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.mainFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.mainFeed.count))
    view.addSubview(childView.view)
    view.isScrollEnabled = isChangable
    view.showsVerticalScrollIndicator = false
    view.showsHorizontalScrollIndicator = false
    view.contentInsetAdjustmentBehavior = .never
    view.isPagingEnabled = true
    view.delegate = context.coordinator
    let customRefreshView = UIHostingController(rootView: CustomRefresh())
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = .clear
    customRefreshView.view.frame = CGRect(
      x: (UIScreen.main.bounds.width - customRefreshView.view.frame.width) / 2,
      y: 100,
      width: customRefreshView.view.frame.width,
      height: customRefreshView.view.frame.height)
//    refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refresh), for: .valueChanged)
    refreshControl.addSubview(customRefreshView.view)
    view.refreshControl = refreshControl
    return view
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    if context.coordinator.parent.refreshableModel.isRefreshing {
      uiView.refreshControl?.beginRefreshing()
    } else {
      uiView.refreshControl?.endRefreshing()
    }
    uiView.contentSize = CGSize(
      width: UIScreen.width,
      height: UIScreen.height * CGFloat(apiViewModel.mainFeed.count))

    for i in 0 ..< uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.mainFeed.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    MainFeedPageView.Coordinator(
      parent: self,
      index: $index,
      changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {
    var parent: MainFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(
      parent: MainFeedPageView,
      index: Binding<Int>,
      changable: Binding<Bool>)
    {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.apiViewModel.mainFeed.isEmpty {
        if index == 0 {
          parent.feedPlayersViewModel.initialPlayers()
        } else {
          parent.feedPlayersViewModel.initialPlayers(index: index)
        }
        parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        if BlockList.shared.userIds.contains(parent.currentContentInfo?.userId ?? 0) {
          return
        }
        WhistleLogger.logger.debug("MainFeedPageView onAppear()")
        if parent.mainFeedTabModel.isAllTab {
          parent.feedPlayersViewModel.currentPlayer?.pause()
          parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
          parent.feedPlayersViewModel.currentPlayer?.play()
        }
      }
    }

    func onDisappear() {
      parent.feedPlayersViewModel.currentPlayer?.pause()
      parent.feedPlayersViewModel.resetPlayer()
      WhistleLogger.logger.debug("MainFeedPageView onDisappear()")
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.scrolledContentCount += 1
      parent.viewedContenId.insert(APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].contentId!)
      let viewDate = parent.viewDuration.toDate()
      let nowDate = Date.now
      let viewTime = nowDate.timeIntervalSince(viewDate ?? Date.now)
      let viewTimeInt = Int(viewTime)
      Mixpanel.mainInstance().track(event: "play_next", properties: [
        "follow": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].isFollowed,
        "whistle": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].isWhistled,
        "bookmark": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].isBookmarked,
        "not_interested": false,
        "content_duration": viewTimeInt,
        "content_id": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].contentId!,
        "content_length": 0,
        "content_caption": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].caption ?? "",
        "hashtags": APIViewModel.shared.mainFeed[parent.feedPlayersViewModel.currentVideoIndex].hashtags ?? [],
      ])
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.mainFeed.count - 1 {
          WhistleLogger.logger.debug("ScrollLast")
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.mainFeed[index]
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
      if scrollView.contentOffset.y <= -scrollView.contentInset.top {
        index = 0
        parent.feedPlayersViewModel.currentVideoIndex = 0
        parent.feedPlayersViewModel.stopPlayer()
        parent.feedPlayersViewModel.resetPlayer()
        parent.feedPlayersViewModel.initialPlayers()
        if BlockList.shared.userIds.contains(parent.currentContentInfo?.userId ?? 0) {
          return
        }
        parent.feedPlayersViewModel.currentPlayer?.play()
      }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
      if scrollView.contentOffset.y < -scrollView.contentInset.top {
        refresh()
      }
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard parent.timer == nil else {
        return
      }

      let offsetY = scrollView.contentOffset.y
      let contentHeight = scrollView.contentSize.height
      let scrollViewHeight = scrollView.frame.size.height

      if offsetY > contentHeight - scrollViewHeight {
        parent.toastViewModel.toastInit(message: "모두 시청했습니다")
        parent.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
          self?.parent.timer?.invalidate()
          self?.parent.timer = nil
        }
      }
    }

    @objc
    func refresh() {
      parent.feedPlayersViewModel.stopPlayer()
      parent.refreshableModel.isRefreshing = true
      parent.refreshableModel.refresh()
    }
  }
}

// MARK: - MainRefreshableModel

class MainRefreshableModel: ObservableObject {
  @Published var isRefreshing = false
  @Published var apiViewModel = APIViewModel.shared
  @Published var feedPlayersViewModel = MainFeedPlayersViewModel.shared

  func refresh() {
    apiViewModel.requestMainFeed { _ in
      self.feedPlayersViewModel.stopPlayer()
      self.feedPlayersViewModel.initialPlayers()
      self.apiViewModel.publisherSend()
      self.feedPlayersViewModel.currentPlayer?.play()
      self.isRefreshing = false
    }
  }
}
