//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import SwiftUI

// MARK: - MainFeedView

struct MainFeedView: View {

  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MainFeedMoreModel.shared
  @State var index = 0

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.mainFeed.isEmpty {
        MainFeedPageView(index: $index)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .confirmationDialog("", isPresented: $feedMoreModel.showDialog) {
      if !apiViewModel.mainFeed.isEmpty {
        Button(CommonWords().hide, role: .none) {
          toastViewModel.cancelToastInit(message: ToastMessages().hiddenContent) {
            Task {
              let currentContent = apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0)
              feedPlayersViewModel.removePlayer {
                index -= 1
              }
            }
          }
        }
        if apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0 != apiViewModel.myProfile.userId {
          Button("신고", role: .destructive) {
            feedPlayersViewModel.stopPlayer()
            feedMoreModel.showReport = true
          }
        }
        Button(CommonWords().close, role: .cancel) { }
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
      if apiViewModel.mainFeed.isEmpty {
        if universalRoutingModel.isUniversalContent {
          apiViewModel.requestUniversalFeed(contentID: universalRoutingModel.contentId) {
            universalRoutingModel.isUniversalContent = false
            feedPlayersViewModel.currentPlayer?.seek(to: .zero)
            feedPlayersViewModel.currentPlayer?.play()
          }
        } else {
          apiViewModel.requestMainFeed { }
        }
      }
    }
    .navigationDestination(isPresented: $feedMoreModel.isRootStacked) {
      if universalRoutingModel.isUniversalProfile {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEMemberProfileView(userId: universalRoutingModel.userId)
              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          default:
            MemberProfileView(userId: universalRoutingModel.userId)
              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          }
        }
      } else {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            if !apiViewModel.mainFeed.isEmpty {
              SEMemberProfileView(
                userId: apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
            }
          default:
            if !apiViewModel.mainFeed.isEmpty {
              MemberProfileView(userId: apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
            }
          }
        }
      }
    }
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      feedPlayersViewModel.currentPlayer?.play()
    }) {
      MainFeedReportReasonSelectionView(
        goReport: $feedMoreModel.showReport,
        contentId: apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex].contentId ?? 0,
        userId: apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
    }
  }
}

// MARK: - MainFeedMoreModel

class MainFeedMoreModel: ObservableObject {
  static let shared = MainFeedMoreModel()
  private init() { }
  @Published var showDialog = false
  @Published var showReport = false
  @Published var showUpdate = false

  @Published var isRootStacked = false
}
