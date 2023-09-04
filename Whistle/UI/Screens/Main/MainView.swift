//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import SwiftUI
import VTabView

struct MainView: View {

  @State private var videos = MockData().videos

  var body: some View {
    ZStack {
      PlayerPageView(videos: $videos)
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }
}

#Preview {
  MainView()
}
