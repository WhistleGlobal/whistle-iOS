//
//  SearchFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import SwiftUI

// MARK: - SearchFeedPageView

struct SearchFeedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = SearchPlayersViewModel.shared
  @State var currentContentInfo: MainContent?
  @State var isChangable = true

  @Binding var index: Int
  let dismissAction: DismissAction

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: SearchContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
        isChangable: $isChangable,
        lifecycleDelegate: context.coordinator,
        dismissAction: dismissAction)
        .toolbarRole(.editor))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.searchedContent.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.searchedContent.count))
    view.addSubview(childView.view)
    view.isScrollEnabled = isChangable
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
      height: UIScreen.height * CGFloat(apiViewModel.searchedContent.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.searchedContent.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    SearchFeedPageView.Coordinator(parent: self, index: $index, changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: SearchFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(parent: SearchFeedPageView, index: Binding<Int>, changable: Binding<Bool>) {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.apiViewModel.searchedContent.isEmpty {
        parent.currentContentInfo = parent.apiViewModel.searchedContent[index]
        parent.feedPlayersViewModel.currentVideoIndex = index
        parent.feedPlayersViewModel.initialPlayers(index: index)
        parent.feedPlayersViewModel.currentPlayer?.seek(to: .zero)
        parent.feedPlayersViewModel.currentPlayer?.play()
      }
    }

    func onDisappear() {
      parent.feedPlayersViewModel.stopPlayer()
      parent.feedPlayersViewModel.resetPlayer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.searchedContent.count - 1 {
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.searchedContent[index]
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
      if scrollView.contentOffset.y <= -scrollView.contentInset.top {
        index = 0
        parent.feedPlayersViewModel.currentVideoIndex = 0
        parent.feedPlayersViewModel.stopPlayer()
        parent.feedPlayersViewModel.resetPlayer()
        parent.feedPlayersViewModel.initialPlayers()
        parent.feedPlayersViewModel.currentPlayer?.play()
      }
    }
  }
}
