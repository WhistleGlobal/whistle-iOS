//
//  BookmarkedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import SwiftUI

// MARK: - BookmarkedPageView

struct BookmarkedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = BookmarkedPlayersViewModel.shared
  @State var currentContentInfo: Bookmark?
  @Binding var index: Int
  let dismissAction: DismissAction

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: BookmarkedContentPlayerview(
        currentContentInfo: $currentContentInfo,
        index: $index,
        lifecycleDelegate: context.coordinator,
        dismissAction: dismissAction))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.bookmark.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.bookmark.count))
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
      height: UIScreen.height * CGFloat(apiViewModel.bookmark.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.bookmark.count))
    }
  }

  func makeCoordinator() -> Coordinator {
    BookmarkedPageView.Coordinator(parent: self, index: $index)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: BookmarkedPageView
    @Binding var index: Int

    init(parent: BookmarkedPageView, index: Binding<Int>) {
      self.parent = parent
      _index = index
    }

    func onAppear() {
      if !parent.apiViewModel.bookmark.isEmpty {
        parent.currentContentInfo = parent.apiViewModel.bookmark[index]
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
        if index == parent.apiViewModel.bookmark.count - 1 {
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.bookmark[index]
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
