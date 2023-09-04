//
//  PlayerView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVKit
import Foundation
import SwiftUI

// MARK: - ViewLifecycleDelegate

protocol ViewLifecycleDelegate {
  func onAppear()
  func onDisappear()
}

// MARK: - Player

struct Player : UIViewControllerRepresentable {

  var player : AVPlayer

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    view.player = player
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspectFill
    return view
  }

  func updateUIViewController(_: AVPlayerViewController, context _: Context) { }
}

// MARK: - PlayerView

struct PlayerView : View {
  @Binding var videos : [Video]
  let lifecycleDelegate: ViewLifecycleDelegate?


  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<videos.count) { i in
        ZStack {
          Player(player: videos[i].player)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .offset(y: -5)
        }
      }
    }
    .onAppear {
      lifecycleDelegate?.onAppear()
    }
    .onDisappear {
      lifecycleDelegate?.onDisappear()
    }
  }
}

// MARK: - PlayerPageView

struct PlayerPageView : UIViewRepresentable {

  class Coordinator : NSObject, UIScrollViewDelegate, ViewLifecycleDelegate {

    // MARK: Lifecycle

    init(parent1 : PlayerPageView) {
      parent = parent1
    }

    // MARK: Internal

    var parent : PlayerPageView
    var index = 0

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      let currentindex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)

      if index != currentindex {
        parent.videos[index].player.seek(to: .zero)
        parent.videos[index].player.pause()
        index = currentindex
        parent.videos[index].player.play()
        parent.videos[index].player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
          forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: parent.videos[index].player.currentItem,
          queue: .main)
        { _ in
          self.parent.videos[self.index].player.seek(to: .zero)
          self.parent.videos[self.index].player.play()
        }
      }
    }

    func onAppear() {
      parent.videos[index].player.seek(to: .zero)
      parent.videos[index].player.play()
    }

    func onDisappear() {
      parent.videos[index].player.seek(to: .zero)
      parent.videos[index].player.pause()
    }

  }


  @Binding var videos : [Video]

  func makeCoordinator() -> Coordinator {
    PlayerPageView.Coordinator(parent1: self)
  }

  func makeUIView(context: Context) -> UIScrollView {
    let view = UIScrollView()

    let childView = UIHostingController(rootView: PlayerView(videos: $videos, lifecycleDelegate: context.coordinator))
    childView.view.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * CGFloat(videos.count))
    view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat(videos.count))

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
      height: UIScreen.main.bounds.height * CGFloat(videos.count))

    for i in 0..<uiView.subviews.count {
      uiView.subviews[i].frame = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height * CGFloat(videos.count))
    }
  }
}

// MARK: - Video

struct Video : Identifiable {
  var id = UUID()
  var player : AVPlayer
  var likes: String
  var comments: String
  var url: String
}

// MARK: - ReelsContainerView

struct ReelsContainerView: View {

  @State private var index = 0
  @State private var top = 0
  @State private var videos = MockData().videos

  var body: some View {
    ZStack {
      PlayerPageView(videos: $videos)
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }
}

// MARK: - MockData

struct MockData: Observable {

  let videos: [Video] = [
    Video(
      player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
      likes: "1M",
      comments: "22.7k",
      url: "http://35.72.228.224/adaStudy/test.mp4"),
    Video(
      player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
      likes: "297",
      comments: "4",
      url: "http://35.72.228.224/adaStudy/test2.mp4"),
    Video(
      player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
      likes: "2.7M",
      comments: "222.7k",
      url: "http://35.72.228.224/adaStudy/test.mp4"),
    Video(
      player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
      likes: "25k",
      comments: "1.1k",
      url: "http://35.72.228.224/adaStudy/test2.mp4")
  ]
}


