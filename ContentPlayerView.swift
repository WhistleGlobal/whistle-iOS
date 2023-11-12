//
//  ContentPlayerView.swift
//  Whistle
//
//  Created by 박상원 on 11/11/23.
//

import SwiftUI

struct ContentPlayerView: View {
  @StateObject var feedMoreModel = MainFeedMoreModel.shared
  @StateObject var feedplayerMovel = MainFeedPlayersViewModel.shared
  var body: some View {
    Text("")
//    ContentLayer(
//      feedMoreModel: MainFeedMoreModel.shared,
//      feedPlayersViewModel: MainFeedPlayersViewModel.shared,
//      whistleAction: { })
  }
}

#Preview {
  ContentPlayerView()
}
