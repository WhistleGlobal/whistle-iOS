//
//  MemberFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/31/23.
//

import SwiftUI

// MARK: - MemberFeedPageView

struct MemberFeedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MemeberPlayersViewModel.shared
  @State var currentContentInfo: MemberContent?
  @Binding var index: Int
  let dismissAction: DismissAction

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MemberContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
        lifecycleDelegate: context.coordinator,
        dismissAction: dismissAction))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.memberFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.memberFeed.count))
    view.addSubview(childView.view)
    view.showsVerticalScrollIndicator = false
    view.showsHorizontalScrollIndicator = false
    view.contentInsetAdjustmentBehavior = .never
    view.isPagingEnabled = true
    view.delegate = context.coordinator
    let yOffset = CGFloat(index) * UIScreen.height
    view.contentOffset = CGPoint(x: 0, y: yOffset)
    return view
  }

  func updateUIView(_ uiView: UIScrollView, context _: Context) {
    uiView.contentSize = CGSize(
      width: UIScreen.width,
      height: UIScreen.height * CGFloat(apiViewModel.memberFeed.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.memberFeed.count))
    }
  }

  func makeCoordinator() -> Coordinator {
    MemberFeedPageView.Coordinator(parent: self, index: $index)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: MemberFeedPageView
    @Binding var index: Int

    init(parent: MemberFeedPageView, index: Binding<Int>) {
      self.parent = parent
      _index = index
    }

    func onAppear() {
      if !parent.apiViewModel.memberFeed.isEmpty {
        parent.currentContentInfo = parent.apiViewModel.memberFeed[index]
        parent.feedPlayersViewModel.currentVideoIndex = index
        parent.feedPlayersViewModel.initialPlayers(index: index)
        parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        if parent.currentContentInfo?.isHated ?? false {
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
        if index == parent.apiViewModel.memberFeed.count - 1 {
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.memberFeed[index]
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
      if scrollView.contentOffset.y <= -scrollView.contentInset.top {
        index = 0
        parent.feedPlayersViewModel.currentVideoIndex = 0
        parent.feedPlayersViewModel.stopPlayer()
        parent.feedPlayersViewModel.resetPlayer()
        parent.feedPlayersViewModel.initialPlayers()
        if parent.currentContentInfo?.isHated ?? false {
          return
        }
        parent.feedPlayersViewModel.currentPlayer?.play()
      }
    }
  }
}
