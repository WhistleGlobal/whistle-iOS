//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import BottomSheet
import Mixpanel
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
  @StateObject private var mainFeedTabModel = MainFeedTabModel.shared
  @StateObject var page: Page = .first()
  @State var uploadingThumbnail = Image("noVideo")
  @State var uploadProgress = 0.0
  @State var isUploading = false
  @State var allIndex = 0
  @State var myTeamIndex = 0
  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false
  @State var myTeamSheetPosition: BottomSheetPosition = .hidden

  @State var playDuration = Date().toString()
  @State var myTeamViewDuration = Date().toString()
  @State var allViewDuration = Date().toString()
  @State var allViewedContentId: Set<Int> = []
  @State var myTeamViewedContentId: Set<Int> = []
  @State var scrolledContentCount = 0

  var body: some View {
    Pager(page: page, data: [MainFeedTabSelection.myteam, MainFeedTabSelection.all]) { selection in
      feedPager(selection: selection)
    }
    .singlePagination(ratio: 0.33, sensitivity: .low)
    .preferredItemSize(CGSize(width: UIScreen.width, height: UIScreen.height))
    .onPageChanged { index in
      if index == 0 {
        mainFeedPlayersViewModel.stopPlayer()
        mainFeedTabModel.switchTab(to: .myteam)
        if myTeamfeedPlayersViewModel.currentPlayer?.rate == 0.0 {
          myTeamfeedPlayersViewModel.currentPlayer?.play()
          myTeamViewDuration = Date().toString()
          WhistleLogger.logger.debug("MainFeedView onPageChanged index 0")
        }
        if apiViewModel.myProfile.myTeam == nil {
          tabbarModel.tabbarOpacity = 0.0
          myTeamSheetPosition = .dynamic
        }
      } else {
        myTeamfeedPlayersViewModel.stopPlayer()
        mainFeedTabModel.switchTab(to: .all)
        if mainFeedPlayersViewModel.currentPlayer?.rate == 0.0 {
          mainFeedPlayersViewModel.currentPlayer?.play()
          WhistleLogger.logger.debug("MainFeedView onPageChanged index 1")
          allViewDuration = Date().toString()
        }
      }
    }
    .background(Color.black)
    .ignoresSafeArea()
    .onChange(of: isUploading) { value in
      if !value {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          toastViewModel.toastInit(message: ToastMessages().contentUploaded)
        }
      }
    }
    .onReceive(UploadProgressViewModel.shared.isUploadingSubject) { value in
      switch value {
      case true:
        withAnimation {
          isUploading = value
        }
      case false:
        withAnimation {
          isUploading = value
        }
      }
    }
    .onReceive(UploadProgressViewModel.shared.thumbnailSubject) { value in
      uploadingThumbnail = value
    }
    .onReceive(UploadProgressViewModel.shared.progressSubject) { value in
      uploadProgress = value
    }
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
              if mainFeedTabModel.isAllTab {
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
    .bottomSheet(
      bottomSheetPosition: $myTeamSheetPosition,
      switchablePositions: [.hidden, .dynamic])
    {
      VStack(spacing: 0) {
        HStack {
          Spacer()
          Button {
            myTeamSheetPosition = .hidden
            withAnimation {
              mainFeedTabModel.switchTab(to: .all)
              page.update(.moveToLast)
              myTeamfeedPlayersViewModel.stopPlayer()
              mainFeedPlayersViewModel.currentPlayer?.play()
            }
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.LabelColor_Primary_Dark)
          }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .padding(.bottom, 36)
        Text("아직 마이팀이 없으신가요?")
          .font(Font.custom("Apple SD Gothic Neo", size: 24))
          .fontWeight(.bold)
          .foregroundColor(.LabelColor_Primary_Dark)
          .padding(.bottom, 8)
        Text("응원하는 구단을 선택하고 맞춤 콘텐츠를 즐겨보세요")
          .fontSystem(fontDesignSystem: .body2)
          .foregroundColor(.LabelColor_Primary_Dark)
          .padding(.bottom, 55)
        HStack(spacing: 0) {
          Image("lotteCard")
            .resizable()
            .scaledToFit()
            .frame(width: 126, height: 168)
            .rotationEffect(Angle(degrees: -12))
            .offset(x: 62)
          Color.clear
            .frame(width: 158, height: 211)
          Image("ssgCard")
            .resizable()
            .scaledToFit()
            .frame(width: 126, height: 168)
            .rotationEffect(Angle(degrees: 12))
            .offset(x: -62)
        }
        .overlay {
          Image("samsungCard")
            .resizable()
            .scaledToFit()
            .frame(width: 158, height: 211)
        }
        .padding(.bottom, 55)
        .shadow(
          color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8.80, y: 1.10)
        NavigationLink {
          MyTeamSelectView()
            .onAppear {
              myTeamSheetPosition = .hidden
            }
        } label: {
          Text("마이팀 선택하기")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: UIScreen.width - 32, height: 47)
            .background {
              Capsule()
                .foregroundColor(.Primary_Default)
            }
        }
        .padding(.bottom, 24)
        Text("마이팀은 선택 후 프로필 탭에서 언제든 변경할 수 있습니다.")
          .fontSystem(fontDesignSystem: .caption_Regular)
          .foregroundColor(.LabelColor_Primary_Dark)
        Spacer()
      }
      .frame(width: UIScreen.width, height: 610)
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
            WhistleLogger.logger.debug("MyTeamFeed Download Failure")
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
              LaunchScreenViewModel.shared.feedDownloaded()
            case .failure:
              WhistleLogger.logger.debug("MainFeed Download Failure")
              apiViewModel.requestMainFeed { _ in }
            }
          }
        }
      }
    }
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      if mainFeedTabModel.isAllTab {
        mainFeedPlayersViewModel.currentPlayer?.play()
      } else {
        myTeamfeedPlayersViewModel.currentPlayer?.play()
      }
    }) {
      if mainFeedTabModel.isAllTab {
        MainFeedReportReasonSelectionView(
          goReport: $feedMoreModel.showReport,
          contentId: apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex].contentId ?? 0,
          userId: apiViewModel.mainFeed[mainFeedPlayersViewModel.currentVideoIndex].userId ?? 0)
      } else {
        MainFeedReportReasonSelectionView(
          goReport: $feedMoreModel.showReport,
          contentId: apiViewModel.myTeamFeed[myTeamfeedPlayersViewModel.currentVideoIndex].contentId ?? 0,
          userId: apiViewModel.myTeamFeed[myTeamfeedPlayersViewModel.currentVideoIndex].userId ?? 0)
      }
    }
    .onChange(of: tabbarModel.tabSelection) { selection in
      if selection == .main, !feedMoreModel.isRootStacked {
        if mainFeedTabModel.isAllTab {
          mainFeedPlayersViewModel.currentPlayer?.play()
        } else {
          myTeamfeedPlayersViewModel.currentPlayer?.play()
        }
        return
      }
      mainFeedPlayersViewModel.stopPlayer()
    }
    .overlay(alignment: .top) {
      HStack {
        Spacer()
        Text("마이팀")
          .fontSystem(fontDesignSystem: .subtitle2)
          .scaleEffect(mainFeedTabModel.isMyTeamTab ? 1.1 : 1.0)
          .onTapGesture {
            withAnimation {
              mainFeedTabModel.switchTab(to: .myteam)
              page.update(.moveToFirst)
              mainFeedPlayersViewModel.stopPlayer()
              mainFeedTabModel.switchTab(to: .myteam)
              myTeamfeedPlayersViewModel.currentPlayer?.play()
            }
          }
        Rectangle()
          .fill(Color.white)
          .frame(width: 1, height: 12)
        Text("전체")
          .fontSystem(fontDesignSystem: .subtitle2)
          .scaleEffect(mainFeedTabModel.isAllTab ? 1.1 : 1.0)
          .onTapGesture {
            withAnimation {
              mainFeedTabModel.switchTab(to: .all)
              page.update(.moveToLast)
              myTeamfeedPlayersViewModel.stopPlayer()
              mainFeedPlayersViewModel.currentPlayer?.play()
            }
          }
        Spacer()
      }
      .foregroundColor(.white)
      .overlay(alignment: .trailing) {
        NavigationLink {
          MainSearchView()
        } label: {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 24))
            .foregroundStyle(Color.white)
        }
        .id(UUID())
      }
      .padding(.horizontal, 16)
      .padding(.top, 54)
      .ignoresSafeArea()
    }
    .overlay(alignment: .topLeading) {
      if isUploading {
        uploadingThumbnail
          .resizable()
          .frame(width: 64, height: 64)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.48))
              RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.Border_Default_Dark)
              CircularProgressBar(progress: UploadProgressViewModel.shared.progress, width: 2)
                .padding(8)
              Text("\(Int(uploadProgress * 100))%")
                .foregroundStyle(Color.white)
                .fontSystem(fontDesignSystem: .body2)
            }
          }
          .padding(.top, 70)
          .padding(.leading, 16)
      }
    }
    .onAppear {
      feedMoreModel.isRootStacked = false
      tabbarModel.showTabbar()
      if mainFeedTabModel.isMyTeamTab {
        if myTeamfeedPlayersViewModel.currentVideoIndex != 0 {
          myTeamfeedPlayersViewModel.currentPlayer?.seek(to: .zero)
          if
            BlockList.shared.userIds
              .contains(apiViewModel.myTeamFeed[myTeamfeedPlayersViewModel.currentVideoIndex].userId ?? 0)
          {
            return
          }
        }
        WhistleLogger.logger.debug("MainFeedView onAppear if")
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
        WhistleLogger.logger.debug("MainFeedView onAppear else")
      }
      if apiViewModel.myProfile.myTeam == nil {
        mainFeedTabModel.switchTab(to: .all)
        page.update(.moveToLast)
      }
      Mixpanel.mainInstance().track(event: "play_start")
      playDuration = Date().toString()
      allViewedContentId = []
      myTeamViewedContentId = []
      scrolledContentCount = 0
    }
    .onDisappear {
      if tabbarModel.tabSelection == .main {
        feedMoreModel.isRootStacked = true
      }
      mainFeedPlayersViewModel.stopPlayer()
      myTeamfeedPlayersViewModel.stopPlayer()
      mainFeedPlayersViewModel.resetPlayer()
      myTeamfeedPlayersViewModel.resetPlayer()
      let viewDate = playDuration.toDate()
      let nowDate = Date.now
      let viewTime = nowDate.timeIntervalSince(viewDate ?? Date.now)
      let viewTimeInt = Int(viewTime)
      Mixpanel.mainInstance().track(event: "play_complete", properties: [
        "play_duration": "\(viewTimeInt)",
        "viewed_contents_count": "\(allViewedContentId.count + myTeamViewedContentId.count)",
        "scrolled_contents_count": "\(scrolledContentCount)",
      ])
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
        MainFeedPageView(
          viewDuration: $allViewDuration,
          viewedContenId: $allViewedContentId,
          scrolledContentCount: $scrolledContentCount,
          index: $allIndex)
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
        MyTeamFeedPageView(
          viewDuration: $myTeamViewDuration,
          viewedContenId: $myTeamViewedContentId,
          scrolledContentCount: $scrolledContentCount,
          index: $myTeamIndex)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
  }

  @ViewBuilder
  func feedPager(selection: MainFeedTabSelection) -> some View {
    switch selection {
    case .all:
      if apiViewModel.mainFeed.isEmpty {
        Color.black
      } else {
        allFeedTab()
          .onAppear {
            if apiViewModel.myProfile.myTeam != nil {
              mainFeedTabModel.switchTab(to: .myteam)
              page.update(.moveToFirst)
              mainFeedPlayersViewModel.stopPlayer()
              mainFeedTabModel.switchTab(to: .myteam)
              myTeamfeedPlayersViewModel.currentPlayer?.play()
            }
          }
      }
    case .myteam:
      myTeamFeedTab()
    }
  }
}
