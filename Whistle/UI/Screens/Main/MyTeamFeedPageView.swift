//
//  MyTeamFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/22/23.
//

import SwiftUI

// MARK: - MyTeamFeedPageView

struct MyTeamFeedPageView: UIViewRepresentable {
  @ObservedObject var refreshableModel = MainRefreshableModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MyTeamFeedPlayersViewModel.shared
  @State var currentContentInfo: MainContent?
  @State var isChangable = true
  @Binding var index: Int

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MyTeamContentPlayerView(
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
    MyTeamFeedPageView.Coordinator(parent: self, index: $index, changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {
    var parent: MyTeamFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(parent: MyTeamFeedPageView, index: Binding<Int>, changable: Binding<Bool>) {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.apiViewModel.mainFeed.isEmpty {
        if index == 0 {
          parent.feedPlayersViewModel.initialPlayers()
        }
        parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        if BlockList.shared.userIds.contains(parent.currentContentInfo?.userId ?? 0) {
          return
        }
        parent.feedPlayersViewModel.currentPlayer?.play()
      }
    }

    func onDisappear() { }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.mainFeed.count - 1 {
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

    @objc
    func refresh() {
      parent.feedPlayersViewModel.stopPlayer()
      parent.refreshableModel.isRefreshing = true
      parent.refreshableModel.refresh()
    }
  }
}
