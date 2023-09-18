//
//  PlayerPageView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVFoundation
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
        parent.apiViewModel.contentList[index].player?.seek(to: .zero)
        parent.apiViewModel.contentList[index].player?.pause()
        if currentindex != 0, currentindex != parent.apiViewModel.contentList.count - 1 {
          let urlNext = parent.apiViewModel.contentList[currentindex + 1].videoUrl
          let urlPrev = parent.apiViewModel.contentList[currentindex - 1].videoUrl
          // 위(이전) 컨텐츠 확인
          if index > currentindex {
            if index != parent.apiViewModel.contentList.count - 1 {
              parent.apiViewModel.contentList[index + 1].player = nil
            }
          } else { // 아래의 컨텐츠 확인
            if index != 0 {
              parent.apiViewModel.contentList[index - 1].player = nil
            }
          }
          parent.apiViewModel.contentList[currentindex + 1].player = AVPlayer(url: URL(string: urlNext ?? "")!)
          parent.apiViewModel.contentList[currentindex - 1].player = AVPlayer(url: URL(string: urlPrev ?? "")!)
          parent.apiViewModel.postFeedPlayerChanged()
        }
        index = currentindex
        parent.apiViewModel.contentList[index].player?.play()
        parent.apiViewModel.contentList[index].player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
          forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: parent.apiViewModel.contentList[index].player?.currentItem,
          queue: .main)
        { _ in
          self.parent.apiViewModel.contentList[self.index].player?.seek(to: .zero)
          self.parent.apiViewModel.contentList[self.index].player?.play()
        }
      }
    }

    func onAppear() {
      parent.apiViewModel.contentList[index].player?.seek(to: .zero)
      parent.apiViewModel.contentList[index].player?.play()
    }

    func onDisappear() {
      parent.apiViewModel.contentList[index].player?.seek(to: .zero)
      parent.apiViewModel.contentList[index].player?.pause()
    }
  }

  @EnvironmentObject var apiViewModel: APIViewModel
  @Binding var videoIndex: Int
  @Binding var currnentVideoIndex: Int

  func makeCoordinator() -> Coordinator {
    PlayerPageView.Coordinator(parent1: self)
  }

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()

    let childView = UIHostingController(
      rootView: PlayerView(lifecycleDelegate: context.coordinator)
        .environmentObject(apiViewModel))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.contentList.count))
    view.contentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.contentList.count))

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
      height: UIScreen.main.bounds.height * CGFloat(apiViewModel.contentList.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height * CGFloat(apiViewModel.contentList.count))
    }
  }
}
