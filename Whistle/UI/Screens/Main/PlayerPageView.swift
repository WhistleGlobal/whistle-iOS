//
//  PlayerPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import Foundation
import SwiftUI

// MARK: - PlayerPageView

struct PlayerPageView: UIViewRepresentable {

  class Coordinator: NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    // MARK: Lifecycle

    init(parent1: PlayerPageView) {
      parent = parent1
    }

    // MARK: Internal

    var parent: PlayerPageView
    var index = 0

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      // 새로 이동한 인덱스
      let currentindex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)

      if index != currentindex {
        parent.videoVM.videos[index].player.seek(to: .zero)
        parent.videoVM.videos[index].player.pause()
        index = currentindex
        parent.videoVM.videos[index].player.play()
        parent.videoVM.videos[index].player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
          forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: parent.videoVM.videos[index].player.currentItem,
          queue: .main)
        { _ in
          self.parent.videoVM.videos[self.index].player.seek(to: .zero)
          self.parent.videoVM.videos[self.index].player.play()
        }
      }
    }

    func onAppear() {
      parent.videoVM.videos[index].player.seek(to: .zero)
      parent.videoVM.videos[index].player.play()
    }

    func onDisappear() {
      parent.videoVM.videos[index].player.seek(to: .zero)
      parent.videoVM.videos[index].player.pause()
    }
  }

  @Binding var videoIndex: Int
  @Binding var currnentVideoIndex: Int
  @Binding var videoVM : VideoVM

  func makeCoordinator() -> Coordinator {
    PlayerPageView.Coordinator(parent1: self)
  }

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()

    let childView = UIHostingController(rootView: PlayerView(videoVM: $videoVM, lifecycleDelegate: context.coordinator))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(videoVM.videos.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(videoVM.videos.count))

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
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(videoVM.videos.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height * CGFloat(videoVM.videos.count))
    }
  }
}
