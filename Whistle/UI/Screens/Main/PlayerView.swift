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

// MARK: - PlayerView

struct PlayerView: View {
  @Binding var videoVM: VideoVM
  let lifecycleDelegate: ViewLifecycleDelegate?


  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<$videoVM.videos.count) { i in
        ZStack {
          Player(player: videoVM.videos[i].player)
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
