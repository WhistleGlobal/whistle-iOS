//
//  MemberFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/31/23.
//

import _AVKit_SwiftUI
import SwiftUI

// MARK: - MemberFeedView

struct MemberFeedView: View {

  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = MemeberPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MemberFeedMoreModel.shared
  @State var index = 0
  let userId: Int

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.memberFeed.isEmpty {
        MemberFeedPageView(index: $index, dismissAction: dismiss)
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
      if !apiViewModel.memberFeed.isEmpty {
        Button("관심없음", role: .none) {
          toastViewModel.cancelToastInit(message: "해당 콘텐츠를 숨겼습니다") {
            Task {
              let currentContent = apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex]
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
        Button("닫기", role: .cancel) { }
      }
    }
    .task {
      if apiViewModel.memberFeed.isEmpty {
        await apiViewModel.requestMemberPostFeed(userID: userId)
      }
    }
    .navigationDestination(isPresented: $feedMoreModel.isRootStacked) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1334: // iPhone SE 3rd generation
          if !apiViewModel.memberFeed.isEmpty {
            SEMemberProfileView(
              userId: apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
          }
        default:
          if !apiViewModel.memberFeed.isEmpty {
            MemberProfileView(userId: apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
          }
        }
      }
    }
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      feedPlayersViewModel.currentPlayer?.play()
    }) {
      MainFeedReportReasonSelectionView(
        goReport: $feedMoreModel.showReport,
        contentId: apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex].contentId ?? 0,
        userId: userId)
    }
  }
}

// MARK: - MemberFeedMoreModel

class MemberFeedMoreModel: ObservableObject {
  static let shared = MemberFeedMoreModel()
  private init() { }
  @Published var showDialog = false
  @Published var showReport = false
  @Published var isRootStacked = false
}
