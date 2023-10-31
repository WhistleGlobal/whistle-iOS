//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import BottomSheet
import SwiftUI

// MARK: - MainFeedView

struct MainFeedView: View {

  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MainFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
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
    .bottomSheet(
      bottomSheetPosition: $feedMoreModel.bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(242)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text("더보기")
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.white)
          Spacer()
          Button {
            feedMoreModel.bottomSheetPosition = .hidden
          } label: {
            Text("취소")
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .foregroundColor(.white)
          }
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Divider().frame(width: UIScreen.width)
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          toastViewModel.cancelToastInit(message: "해당 콘텐츠를 숨겼습니다") {
            Task {
              let currentContent = apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0)
              feedPlayersViewModel.removePlayer {
                index -= 1
              }
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "eye.fill", text: "관심없음")
        }
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          feedPlayersViewModel.stopPlayer()
          feedMoreModel.showReport = true
        } label: {
          bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: "신고하기")
        }

        Spacer()
      }
      .frame(height: 242)
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
        })
    .onDismiss {
      tabbarModel.tabbarOpacity = 1.0
    }
    .onChange(of: feedMoreModel.bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
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
  @Published var showReport = false
  @Published var showUpdate = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}
