//
//  GuestMainFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import SwiftUI

// MARK: - MainFeedPageView

struct GuestMainFeedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = GuestFeedPlayersViewModel.shared
  @StateObject private var feedMoreModel = GuestMainFeedMoreModel.shared
  @State var currentContentInfo: GuestContent?
  @State var isChangable = true

  @Binding var index: Int

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: GuestContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
        isChangable: $isChangable,
        lifecycleDelegate: context.coordinator))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.guestFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.guestFeed.count))
    view.addSubview(childView.view)
    view.isScrollEnabled = isChangable
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
      height: UIScreen.height * CGFloat(apiViewModel.guestFeed.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.guestFeed.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    GuestMainFeedPageView.Coordinator(parent: self, index: $index, changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: GuestMainFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(parent: GuestMainFeedPageView, index: Binding<Int>, changable: Binding<Bool>) {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.apiViewModel.guestFeed.isEmpty {
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
      parent.feedPlayersViewModel.resetPlayer()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index <= parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.guestFeed.count - 1 {
          parent.feedMoreModel.bottomSheetPosition = .dynamic
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.guestFeed[index]
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
  }
}
