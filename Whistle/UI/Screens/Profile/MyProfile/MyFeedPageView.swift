//
//  MyFeedPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import SwiftUI

// MARK: - MyFeedPageView

struct MyFeedPageView: UIViewRepresentable {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = MyFeedPlayersViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @State var timer: Timer?
  @State var currentContentInfo: MyContent?
  @State var isChangable = true
  @Binding var index: Int
  let dismissAction: DismissAction

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MyContentPlayerView(
        currentContentInfo: $currentContentInfo,
        index: $index,
        isChangable: $isChangable,
        lifecycleDelegate: context.coordinator,
        dismissAction: dismissAction))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.myFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.myFeed.count))
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
      height: UIScreen.height * CGFloat(apiViewModel.myFeed.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(apiViewModel.myFeed.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    MyFeedPageView.Coordinator(parent: self, index: $index, changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: MyFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(parent: MyFeedPageView, index: Binding<Int>, changable: Binding<Bool>) {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.apiViewModel.myFeed.isEmpty {
        parent.currentContentInfo = parent.apiViewModel.myFeed[index]
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.feedPlayersViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.feedPlayersViewModel.currentVideoIndex {
        if index == parent.apiViewModel.myFeed.count - 1 {
          return
        }
        parent.feedPlayersViewModel.goPlayerNext()
      } else if index > parent.feedPlayersViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.feedPlayersViewModel.goPlayerPrev()
        index = parent.feedPlayersViewModel.currentVideoIndex
      }
      index = parent.feedPlayersViewModel.currentVideoIndex
      parent.currentContentInfo = parent.apiViewModel.myFeed[index]
      scrollView.isScrollEnabled = changable
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
  }
}
