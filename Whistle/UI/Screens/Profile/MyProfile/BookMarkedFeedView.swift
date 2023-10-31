//
//  BookmarkedFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import _AVKit_SwiftUI
import SwiftUI

// MARK: - BookMarkedFeedView

struct BookMarkedFeedView: View {

  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = BookmarkedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = BookmarkedFeedMoreModel.shared
  @State var index = 0

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.bookmark.isEmpty {
        BookmarkedPageView(index: $index, dismissAction: dismiss)
      } else {
        VStack {
          Spacer()
          Text("저장한 콘텐츠가 없습니다")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
          Spacer()
        }
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .confirmationDialog("", isPresented: $feedMoreModel.showDialog) {
      if !apiViewModel.bookmark.isEmpty {
        Button("저장 취소", role: .none) {
          toastViewModel.cancelToastInit(message: "저장 취소되었습니다.") {
            Task {
              let currentContent = apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex]
              _ = await apiViewModel.bookmarkAction(contentID: currentContent.contentId, method: .delete)
              feedPlayersViewModel.removePlayer {
                index -= 1
                apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                  let mutableItem = item
                  if mutableItem.contentId == currentContent.contentId {
                    mutableItem.isBookmarked = false
                  }
                  return mutableItem
                }
              }
            }
          }
        }
        Button("닫기", role: .cancel) { }
      }
    }
    .task {
      let updateAvailable = await apiViewModel.checkUpdateAvailable()
      if updateAvailable {
        await apiViewModel.requestVersionCheck()
        feedMoreModel.showUpdate = apiViewModel.versionCheck.forceUpdate
        if feedMoreModel.showUpdate {
          return
        }
      }
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.bookmark.isEmpty {
        await apiViewModel.requestMyBookmark()
      }
    }
    .navigationDestination(isPresented: $feedMoreModel.isRootStacked) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1334: // iPhone SE 3rd generation
          if !apiViewModel.bookmark.isEmpty {
            SEMemberProfileView(
              userId: apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].userId)
          }
        default:
          if !apiViewModel.bookmark.isEmpty {
            MemberProfileView(userId: apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].userId)
          }
        }
      }
    }
  }
}

// MARK: - BookmarkedFeedMoreModel

class BookmarkedFeedMoreModel: ObservableObject {
  static let shared = BookmarkedFeedMoreModel()
  private init() { }
  @Published var showDialog = false
  @Published var showReport = false
  @Published var showUpdate = false
  @Published var isRootStacked = false
}
