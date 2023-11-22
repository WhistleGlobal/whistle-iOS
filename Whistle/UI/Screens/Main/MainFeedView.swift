//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import BottomSheet
import SwiftUI
import SwiftUIPager

// MARK: - MainFeedView

struct MainFeedView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var mainFeedPlayersViewModel = MainFeedPlayersViewModel.shared
  @StateObject private var myTeamfeedPlayersViewModel = MyTeamFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MainFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var page: Page = .first()
  @State var allIndex = 0
  @State var myTeamIndex = 0
  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false
  @Binding var feedSelection: MainFeedTabSelection

  var body: some View {
    Pager(page: page, data: [MainFeedTabSelection.myteam, MainFeedTabSelection.all]) { selection in
      feedPager(selection: selection)
    }
    .singlePagination(ratio: 0.33, sensitivity: .low)
    .preferredItemSize(CGSize(width: UIScreen.width, height: UIScreen.height))
    .onPageChanged { index in
      if index == 0 {
        mainFeedPlayersViewModel.stopPlayer()
        feedSelection = .myteam
        if myTeamfeedPlayersViewModel.currentPlayer?.rate == 0.0 {
          myTeamfeedPlayersViewModel.currentPlayer?.play()
        }
      } else {
        myTeamfeedPlayersViewModel.stopPlayer()
        feedSelection = .all
        if mainFeedPlayersViewModel.currentPlayer?.rate == 0.0 {
          mainFeedPlayersViewModel.currentPlayer?.play()
        }
      }
    }
    .background(Color.black)
    .ignoresSafeArea()
    .bottomSheet(
      bottomSheetPosition: $feedMoreModel.bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(242)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text(CommonWords().more)
            .fontSystem(fontDesignSystem: .subtitle1)
            .foregroundColor(.white)
          Spacer()
          Button {
            feedMoreModel.bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.white)
          }
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Rectangle().frame(width: UIScreen.width, height: 1).foregroundColor(Color.Border_Default_Dark)
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          toastViewModel.cancelToastInit(message: ToastMessages().postHidden) {
            Task {
              if feedSelection == .all {
                let currentContent = apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex]
                await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0, method: .post)
                mainFeedPlayersViewModel.removePlayer {
                  allIndex -= 1
                }
              } else {
                // FIXME: - 마이팀으로 고칠 것
                let currentContent = apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex]
                await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0, method: .post)
                mainFeedPlayersViewModel.removePlayer {
                  allIndex -= 1
                }
              }
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "eye.slash.fill", text: CommonWords().hide)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          mainFeedPlayersViewModel.stopPlayer()
          feedMoreModel.showReport = true
        } label: {
          bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: CommonWords().reportAction)
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
      tabbarModel.showTabbar()
    }
    .onChange(of: feedMoreModel.bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.showTabbar()
      } else {
        tabbarModel.hideTabbar()
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
      if apiViewModel.myTeamFeed.isEmpty {
        apiViewModel.requestMyTeamFeed { value in
          switch value.result {
          case .success:
            break
          case .failure:
            WhistleLogger.logger.debug("MainFeed Download Failure")
            apiViewModel.requestMyTeamFeed { _ in }
          }
        }
      }
      if apiViewModel.mainFeed.isEmpty {
        if universalRoutingModel.isUniversalContent {
          apiViewModel.requestUniversalFeed(contentID: universalRoutingModel.contentId) {
            universalRoutingModel.isUniversalContent = false
            mainFeedPlayersViewModel.currentPlayer?.seek(to: .zero)
            if mainFeedPlayersViewModel.currentPlayer?.rate == 0.0 {
              mainFeedPlayersViewModel.currentPlayer?.play()
            }
          }
        } else {
          apiViewModel.requestMainFeed { value in
            switch value.result {
            case .success:
              LaunchScreenViewModel.shared.mainFeedDownloaded()
            case .failure:
              WhistleLogger.logger.debug("MainFeed Download Failure")
              apiViewModel.requestMainFeed { _ in }
            }
          }
        }
      }
    }
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      mainFeedPlayersViewModel.currentPlayer?.play()
    }) {
      MainFeedReportReasonSelectionView(
        goReport: $feedMoreModel.showReport,
        contentId: apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex].contentId ?? 0,
        userId: apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex].userId ?? 0)
    }
    .onChange(of: tabbarModel.tabSelection) { selection in
      if selection == .main, !feedMoreModel.isRootStacked {
        mainFeedPlayersViewModel.currentPlayer?.play()
        return
      }
      mainFeedPlayersViewModel.stopPlayer()
    }
    .overlay {
      VStack {
        HStack {
          Color.clear.frame(width: 28, height: 28)
          Spacer()
          Text("마이팀")
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.white)
            .scaleEffect(feedSelection == .myteam ? 1.1 : 1.0)
            .onTapGesture {
              withAnimation {
                feedSelection = .myteam
                page.update(.moveToFirst)
                mainFeedPlayersViewModel.stopPlayer()
                feedSelection = .myteam
                myTeamfeedPlayersViewModel.currentPlayer?.play()
              }
            }

          Divider()
            .background(Color.white).frame(height: 12)
          Text("전체")
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.white)
            .scaleEffect(feedSelection == .all ? 1.1 : 1.0)
            .onTapGesture {
              withAnimation {
                feedSelection = .all
                page.update(.moveToLast)
                myTeamfeedPlayersViewModel.stopPlayer()
                feedSelection = .all
                mainFeedPlayersViewModel.currentPlayer?.play()
              }
            }
            .foregroundColor(.white)
          Spacer()
          NavigationLink {
            MainSearchView()
          } label: {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 24))
              .foregroundColor(.white)
          }
          .frame(width: 28, height: 28)
          .id(UUID())
        }
        .frame(height: 28)
        Spacer()
      }
      .padding(.horizontal, 16)
    }
    .onAppear {
      feedMoreModel.isRootStacked = false
      tabbarModel.showTabbar()
      if feedSelection == .myteam {
        if myTeamfeedPlayersViewModel.currentVideoIndex != 0 {
          myTeamfeedPlayersViewModel.currentPlayer?.seek(to: .zero)
          if
            BlockList.shared.userIds
              .contains(apiViewModel.myTeamFeed[myTeamfeedPlayersViewModel.currentVideoIndex].userId ?? 0)
          {
            return
          }
        }
//        myTeamfeedPlayersViewModel.currentPlayer?.pause()
//        myTeamfeedPlayersViewModel.currentPlayer?.seek(to: .zero)
//        myTeamfeedPlayersViewModel.currentPlayer?.play()
      } else {
        if mainFeedPlayersViewModel.currentVideoIndex != 0 {
          mainFeedPlayersViewModel.currentPlayer?.seek(to: .zero)
          if
            BlockList.shared.userIds
              .contains(apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex].userId ?? 0)
          {
            return
          }
        }
//        mainFeedPlayersViewModel.currentPlayer?.pause()
//        mainFeedPlayersViewModel.currentPlayer?.seek(to: .zero)
//        mainFeedPlayersViewModel.currentPlayer?.play()
      }
    }
    .onDisappear {
      feedMoreModel.isRootStacked = true
      mainFeedPlayersViewModel.stopPlayer()
      myTeamfeedPlayersViewModel.stopPlayer()
    }
  }
}

// MARK: - MainFeedMoreModel

class MainFeedMoreModel: ObservableObject {
  static let shared = MainFeedMoreModel()
  private init() { }
  @Published var showSearch = false
  @Published var showReport = false
  @Published var showUpdate = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}

extension MainFeedView {
  @ViewBuilder
  func allFeedTab() -> some View {
    ZStack {
      Color.black
      if !apiViewModel.mainFeed.isEmpty {
        MainFeedPageView(index: $allIndex, feedSelection: $feedSelection)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }

  @ViewBuilder
  func myTeamFeedTab() -> some View {
    ZStack {
      Color.black
      if !apiViewModel.myTeamFeed.isEmpty {
        MyTeamFeedPageView(index: $myTeamIndex, feedSelection: $feedSelection)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }

  @ViewBuilder
  func feedPager(selection: MainFeedTabSelection) -> some View {
    switch selection {
    case .all:
      allFeedTab()
    case .myteam:
      myTeamFeedTab()
    }
  }
}
