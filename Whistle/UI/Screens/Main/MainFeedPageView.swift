//
//  MainFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import SwiftUI

// MARK: - MainFeedPageView

struct MainFeedPageView: UIViewRepresentable {

  @ObservedObject var refreshableModel = MainRefreshableModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @State var currentContentInfo: MainContent?
  @Binding var index: Int

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MainContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
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
    view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
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

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.mainFeed.count))
    }
  }

  func makeCoordinator() -> Coordinator {
    MainFeedPageView.Coordinator(parent: self, index: $index)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: MainFeedPageView
    @Binding var index: Int

    init(parent: MainFeedPageView, index: Binding<Int>) {
      self.parent = parent
      _index = index
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

    func onDisappear() {
      parent.feedPlayersViewModel.stopPlayer()
    }

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
    apiViewModel.requestMainFeed {
      self.feedPlayersViewModel.stopPlayer()
      self.feedPlayersViewModel.initialPlayers()
      self.apiViewModel.publisherSend()
      self.feedPlayersViewModel.currentPlayer?.play()
      self.isRefreshing = false
    }
  }
}
