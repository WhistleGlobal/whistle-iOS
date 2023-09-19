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
  @State var currentVideoIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showBookmarkToast = false
  @State var showHideContentToast = false
  @State var showFollowToast = (false, "")
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var isShowingBottomSheet = false
  @Binding var tabSelection: TabSelection
  @Binding var tabbarOpacity: Double
  @Binding var tabWidth: CGFloat

  var body: some View {
    ZStack {
      if apiViewModel.contentList.isEmpty {
        Color.white
      } else {
        PlayerPageView(
          videoIndex: $videoIndex,
          currentVideoIndex: $currentVideoIndex,
          currentVideoContentId: $currentVideoContentId,
          showDialog: $showDialog,
          showPasteToast: $showPasteToast,
          showBookmarkToast: $showBookmarkToast,
          showFollowToast: $showFollowToast,
          currentVideoUserId: $currentVideoUserId,
          tabWidth: $tabWidth)
          .environmentObject(apiViewModel)
      }
      Color.clear.overlay {
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
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .onChange(of: tabSelection) { newValue in
      if newValue != .main {
        log("pause")
        apiViewModel.contentList[currentVideoIndex].player?.pause()
      } else {
        log("pause")
        apiViewModel.contentList[currentVideoIndex].player?.play()
      }
    }
    .task {
      if apiViewModel.contentList.isEmpty {
        await apiViewModel.requestContentList()
      }
    }
    .task {
      await apiViewModel.requestMyProfile()
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", paddingBottom: 78, showToast: $showPasteToast)
      }
      if showBookmarkToast {
        ToastMessage(text: "저장되었습니다!", paddingBottom: 78, showToast: $showBookmarkToast)
      }
      if showFollowToast.0 {
        ToastMessage(text: showFollowToast.1, paddingBottom: 78, showToast: $showFollowToast.0)
      }
      if showHideContentToast {
        CancelableToastMessage(text: "해당 콘텐츠를 숨겼습니다", paddingBottom: 78, action: {
          Task {
            await apiViewModel.actionContentHate(contentId: currentVideoContentId)
            apiViewModel.contentList.remove(at: currentVideoIndex)
            guard let url = apiViewModel.contentList[currentVideoIndex + 1].videoUrl else {
              return
            }
            apiViewModel.contentList[currentVideoIndex + 1].player = AVPlayer(url: URL(string: url)!)
            await apiViewModel.contentList[currentVideoIndex].player?.seek(to: .zero)
            apiViewModel.contentList[currentVideoIndex].player?.play()
            apiViewModel.postFeedPlayerChanged()
          }
        }, showToast: $showHideContentToast)
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("저장하기", role: .none) {
        Task {
          showBookmarkToast = await apiViewModel.actionBookmark(contentId: currentVideoContentId)
        }
      }
      Button("관심없음", role: .none) {
        showHideContentToast = true
      }
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
