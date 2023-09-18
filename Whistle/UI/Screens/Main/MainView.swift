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
  @State var showToast = false
  @State var currentVideoUserId = 0
  @State var isShowingBottomSheet = false
  @Binding var tabbarOpacity: Double

  var body: some View {
    ZStack {
      if apiViewModel.contentList.isEmpty {
        Color.white
      } else {
        PlayerPageView(
          videoIndex: $videoIndex,
          currnentVideoIndex: $currnentVideoIndex,
          showDialog: $showDialog,
          showToast: $showToast,
          currentVideoUserId: $currentVideoUserId)
          .environmentObject(apiViewModel)
      }
      VStack {
        Spacer()
        MainReportBottomSheet(isShowing: $isShowingBottomSheet, content: AnyView(Text("")))
          .environmentObject(apiViewModel)
          .onChange(of: isShowingBottomSheet) { newValue in
            if !newValue {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tabbarOpacity = 1
              }
            }
          }
          .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
              .onEnded { value in
                if value.translation.height > 20 {
                  withAnimation {
                    isShowingBottomSheet = false
                  }
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tabbarOpacity = 1
                  }
                }
              })
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .task {
      if apiViewModel.contentList.isEmpty {
        await apiViewModel.requestContentList()
      }
    }
    .overlay {
      if showToast {
        ProfileToastMessage(text: "클립보드에 복사되었어요", paddingBottom: 78, showToast: $showToast)
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("저장하기", role: .none) { }
      Button("관심없음", role: .none) { }
      Button("신고", role: .destructive) {
          tabbarOpacity = 0
          withAnimation {
              isShowingBottomSheet = true
          }
      }
      Button("닫기", role: .cancel) {
        log("Cancel")
      }
    }
  }
}
