//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import SwiftUI

struct MainView: View {

  @EnvironmentObject var apiViewModel: APIViewModel

  @State var videoIndex = 0
  @State var currnentVideoIndex = 0
  var body: some View {
    ZStack {
      PlayerPageView(videoIndex: $videoIndex, currnentVideoIndex: $currnentVideoIndex)
        .environmentObject(apiViewModel)
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }
}
