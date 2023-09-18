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
  @State var showDialog = false

  var body: some View {
    ZStack {
      if apiViewModel.contentList.isEmpty {
        Color.white
      } else {
        PlayerPageView(videoIndex: $videoIndex, currnentVideoIndex: $currnentVideoIndex, showDialog: $showDialog)
          .environmentObject(apiViewModel)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .task {
      if apiViewModel.contentList.isEmpty {
        await apiViewModel.requestContentList()
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("저장하기", role: .none) { }
      Button("관심없음", role: .none) { }
      Button("신고", role: .destructive) { }
      Button("닫기", role: .cancel) {
        log("Cancel")
      }
    }
  }
}
