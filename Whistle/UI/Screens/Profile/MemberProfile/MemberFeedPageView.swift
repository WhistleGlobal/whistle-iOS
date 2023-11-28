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
  @ObservedObject var memberContentViewModel: MemberContentViewModel
  @State var currentContentInfo: MemberContent?
  @State var isChangable = true
  @Binding var index: Int
  let dismissAction: DismissAction

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()
    let childView = UIHostingController(
      rootView: MemberContentPlayerView(
        memberContentViewModel: memberContentViewModel,
        currentContentInfo: $currentContentInfo,
        index: $index,
        isChangable: $isChangable,
        lifecycleDelegate: context.coordinator,
        dismissAction: dismissAction))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(memberContentViewModel.memberFeed.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(memberContentViewModel.memberFeed.count))
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
      height: UIScreen.height * CGFloat(memberContentViewModel.memberFeed.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.width,
        height: UIScreen.height * CGFloat(memberContentViewModel.memberFeed.count))
    }
    uiView.isScrollEnabled = isChangable
  }

  func makeCoordinator() -> Coordinator {
    MemberFeedPageView.Coordinator(parent: self, index: $index, changable: $isChangable)
  }

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    var parent: MemberFeedPageView
    @Binding var index: Int
    @Binding var changable: Bool

    init(parent: MemberFeedPageView, index: Binding<Int>, changable: Binding<Bool>) {
      self.parent = parent
      _index = index
      _changable = changable
    }

    func onAppear() {
      if !parent.memberContentViewModel.memberFeed.isEmpty {
        parent.currentContentInfo = parent.memberContentViewModel.memberFeed[index]
        parent.memberContentViewModel.currentVideoIndex = index
        parent.memberContentViewModel.initialPlayers(index: index)
        parent.memberContentViewModel.currentPlayer?.seek(to: .zero)
        if parent.currentContentInfo?.isHated ?? false {
          return
        }
        parent.memberContentViewModel.currentPlayer?.play()
      }
    }

    func onDisappear() {
      parent.memberContentViewModel.stopPlayer()
      parent.memberContentViewModel.resetPlayer()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      parent.memberContentViewModel.currentVideoIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
      if index < parent.memberContentViewModel.currentVideoIndex {
        if index == parent.memberContentViewModel.memberFeed.count - 1 {
          return
        }
        parent.memberContentViewModel.goPlayerNext()
      } else if index > parent.memberContentViewModel.currentVideoIndex {
        if index == 0 { return }
        parent.memberContentViewModel.goPlayerPrev()
        index = parent.memberContentViewModel.currentVideoIndex
      }
      index = parent.memberContentViewModel.currentVideoIndex
      parent.currentContentInfo = parent.memberContentViewModel.memberFeed[index]
      scrollView.isScrollEnabled = changable
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
      if scrollView.contentOffset.y <= -scrollView.contentInset.top {
        index = 0
        parent.memberContentViewModel.currentVideoIndex = 0
        parent.memberContentViewModel.stopPlayer()
        parent.memberContentViewModel.resetPlayer()
        parent.memberContentViewModel.initialPlayers()
        if parent.currentContentInfo?.isHated ?? false {
          return
        }
        parent.memberContentViewModel.currentPlayer?.play()
      }
    }
  }
}
