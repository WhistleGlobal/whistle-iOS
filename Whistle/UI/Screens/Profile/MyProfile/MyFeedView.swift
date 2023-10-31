//
//  MyFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import _AVKit_SwiftUI
import SwiftUI

// MARK: - MyFeedKitView

struct MyFeedView: View {

  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = MyFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MyFeedMoreModel.shared
  @State var index = 0

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.myFeed.isEmpty {
        MyFeedPageView(index: $index, dismissAction: dismiss)
      } else {
        VStack {
          Spacer()
          Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 60)
            .foregroundColor(.LabelColor_Primary_Dark)
          Text("콘텐츠가 없습니다")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
          Spacer()
        }
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .confirmationDialog("", isPresented: $feedMoreModel.showDialog) {
      if !apiViewModel.myFeed.isEmpty {
        Button("삭제", role: .destructive) {
          toastViewModel.cancelToastInit(message: "삭제되었습니다") {
            Task {
              let currentContent = apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.deleteContent(contentID: currentContent.contentId ?? 0)
              feedPlayersViewModel.removePlayer {
                index -= 1
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
      if apiViewModel.myFeed.isEmpty {
        await apiViewModel.requestMyPostFeed()
      }
    }
    .navigationDestination(isPresented: $feedMoreModel.isRootStacked) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1334: // iPhone SE 3rd generation
          if !apiViewModel.myFeed.isEmpty {
            SEMemberProfileView(
              userId: apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
          }
        default:
          if !apiViewModel.myFeed.isEmpty {
            MemberProfileView(userId: apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
          }
        }
      }
    }
  }
}

// MARK: - MyFeedMoreModel

class MyFeedMoreModel: ObservableObject {
  static let shared = MyFeedMoreModel()
  private init() { }
  @Published var showDialog = false
  @Published var showReport = false
  @Published var showUpdate = false
  @Published var isRootStacked = false
}
