//
//  MainFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import SwiftUI

struct MainFeedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = FeedPlayersViewModel.shared
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
    return view
  }

  func updateUIView(_ uiView: UIScrollView, context _: Context) {
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
      WhistleLogger.logger.debug("onAppear()")
      if index == 0 {
        parent.feedPlayersViewModel.initialPlayers()
      }
      parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
      parent.feedPlayersViewModel.currentPlayer?.play()
    }

    func onDisappear() {
      WhistleLogger.logger.debug("onDisappear()")
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
  }
}
