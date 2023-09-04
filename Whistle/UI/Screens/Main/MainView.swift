//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import SwiftUI

struct MainView: View {
  @State private var videoVm = VideoVM()
  @State var videoIndex = 0
  @State var currnentVideoIndex = 0
  var body: some View {
    ZStack {
      PlayerPageView(videoIndex: $videoIndex, currnentVideoIndex: $currnentVideoIndex, videoVM: $videoVm)
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }
}

#Preview {
  MainView()
}
