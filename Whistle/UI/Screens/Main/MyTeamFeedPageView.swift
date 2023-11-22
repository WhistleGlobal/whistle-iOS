//
//  MyTeamFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/22/23.
//

import SwiftUI

// MARK: - MyTeamFeedPageView

struct MyTeamFeedPageView: UIViewRepresentable {
  @ObservedObject var refreshableModel = MyTeamRefreshableModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MyTeamFeedPlayersViewModel.shared
  @State var currentContentInfo: MainContent?
  @State var isChangable = true
  @Binding var index: Int
  @Binding var feedSelection: MainFeedTabSelection

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
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.myTeamFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.myTeamFeed.count))
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
      height: UIScreen.height * CGFloat(apiViewModel.myTeamFeed.count))

    for i in 0 ..< uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.myTeamFeed.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    MyTeamFeedPageView.Coordinator(
      parent: self,
      index: $index,
      changable: $isChangable,
      feedSelection: $feedSelection)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {
    var parent: MyTeamFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool
    @Binding var feedSelection: MainFeedTabSelection

    init(
      parent: MyTeamFeedPageView,
      index: Binding<Int>,
      changable: Binding<Bool>,
      feedSelection: Binding<MainFeedTabSelection>)
    {
      self.parent = parent
      _index = index
      _changable = changable
      _feedSelection = feedSelection
    }

    func onAppear() {
      if !parent.apiViewModel.myTeamFeed.isEmpty {
        if index == 0 {
          parent.feedPlayersViewModel.initialPlayers()
        } else {
          parent.feedPlayersViewModel.initialPlayers(index: index)
        }
        parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        if BlockList.shared.userIds.contains(parent.currentContentInfo?.userId ?? 0) {
          return
        }
        WhistleLogger.logger.debug("MyTeamFeedPageView onAppear()")
        if feedSelection == .myteam {
          parent.feedPlayersViewModel.currentPlayer?.pause()
          parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
          parent.feedPlayersViewModel.currentPlayer?.play()
        }
      }
    }

    func onDisappear() {
      WhistleLogger.logger.debug("MyTeamFeedPageView onDisappear()")
      parent.feedPlayersViewModel.currentPlayer?.pause()
      parent.feedPlayersViewModel.resetPlayer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.myTeamFeed.count - 1 {
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.myTeamFeed[index]
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
        if feedSelection == .myteam {
          parent.feedPlayersViewModel.currentPlayer?.play()
        }
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

// MARK: - MyTeamRefreshableModel

class MyTeamRefreshableModel: ObservableObject {
  @Published var isRefreshing = false
  @Published var apiViewModel = APIViewModel.shared
  @Published var feedPlayersViewModel = MyTeamFeedPlayersViewModel.shared

  func refresh() {
    apiViewModel.requestMyTeamFeed { _ in
      self.feedPlayersViewModel.stopPlayer()
      self.feedPlayersViewModel.initialPlayers()
      self.apiViewModel.publisherSend()
      self.feedPlayersViewModel.currentPlayer?.play()
      self.isRefreshing = false
    }
  }
}
