//
//  MainFeedView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import AVFoundation
import Combine
import Kingfisher
import SwiftUI

// MARK: - MainFeedView

struct MainFeedView: View {
  @AppStorage("showGuide") var showGuide = true
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared

  @State var viewCount: ViewCount = .init()

  @State var playerIndex = 0
  @State var isCurrentVideoWhistled = false
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var currentVideoIsBookmarked = false
  @State var currentIndex = 0
  @State var players: [AVPlayer?] = []

  @State var showDialog = false
  @State var showReport = false
  @State var showUserProfile = false
  @State var showUpdate = false
  @State var showPlayButton = false

  @State var isShowingBottomSheet = false
  @State var isSplashOn = true
  @State var isUploading = false
  @State var newId = UUID()

  @State var timer: Timer? = nil
  @State var viewTimer: Timer? = nil

  @State var processedContentId: Set<Int> = []
  @State var uploadingThumbnail = Image("noVideo")
  @State var uploadProgress = 0.0

  @Binding var mainOpacity: Double
  @Binding var isRootStacked: Bool
  @Binding var refreshCount: Int
  var cancellables: Set<AnyCancellable> = []

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.mainFeed.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[min(max(0, index), players.count - 1)] {
              ContentPlayer(player: player)
                .frame(width: proxy.size.width)
                .opacity(BlockList.shared.userIds.contains(content.userId ?? 0) ? 0.3 : 1)
                .onTapGesture(count: 2) {
                  whistleToggle()
                }
                .onTapGesture {
                  if player.rate == 0.0 {
                    player.play()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  } else {
                    player.pause()
                    showPlayButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                      withAnimation {
                        showPlayButton = false
                      }
                    }
                  }
                }
                .onLongPressGesture {
                  HapticManager.instance.impact(style: .medium)
                  showDialog = true
                }
                .overlay {
                  LinearGradient(
                    colors: [.clear, .black.opacity(0.24)],
                    startPoint: .center,
                    endPoint: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                  if tabbarModel.tabWidth != 56 {
                    userInfo(
                      contentId: content.contentId ?? 0,
                      userName: content.userName ?? "",
                      profileImg: content.profileImg ?? "",
                      isFollowed:
                      Binding(get: {
                        content.isFollowed
                      }, set: { newValue in
                        content.isFollowed = newValue
                      }),
                      caption: content.caption ?? "",
                      musicTitle: content.musicTitle ?? "원본 오디오",
                      isWhistled: Binding(get: {
                        content.isWhistled
                      }, set: { newValue in
                        content.isWhistled = newValue
                      }),
                      whistleCount:
                      Binding(get: {
                        content.whistleCount
                      }, set: { newValue in
                        content.whistleCount = newValue
                      }))
                      .opacity(BlockList.shared.userIds.contains(content.userId ?? 0) ? 0 : 1)
                  }
                  playButton(toPlay: player.rate == 0)
                    .opacity(showPlayButton ? 1 : 0)
                    .allowsHitTesting(false)
                  if BlockList.shared.userIds.contains(content.userId ?? 0) {
                    KFImage.url(URL(string: content.thumbnailUrl ?? ""))
                      .placeholder {
                        Color.black
                      }
                      .resizable()
                      .scaledToFill()
                      .tag(index)
                      .frame(width: proxy.size.width)
                      .padding()
                      .rotationEffect(Angle(degrees: -90))
                      .ignoresSafeArea(.all, edges: .top)
                      .blur(radius: 30)
                      .overlay {
                        VStack {
                          Image(systemName: "eye.slash.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.Gray10)
                            .padding(.bottom, 26)
                          Text("차단된 계정의 콘텐츠입니다.")
                            .fontSystem(fontDesignSystem: .subtitle1_KO)
                            .foregroundColor(.LabelColor_Primary_Dark)
                            .padding(.bottom, 12)
                          Text("차단된 계정의 모든 콘텐츠는 \n회원님의 피드에 노출되지 않습니다.")
                            .fontSystem(fontDesignSystem: .body2_KO)
                            .foregroundColor(.LabelColor_Secondary_Dark)
                        }
                      }
                  }
                }
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
                .tag(index)
                .onAppear {
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  let dateString = dateFormatter.string(from: .now)
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    viewCount.views[index].viewDate = dateString
                  } else {
                    viewCount.views.append(.init(contentId: content.contentId ?? 0, viewDate: dateString))
                  }
                }
                .onDisappear {
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    let viewDate = viewCount.views[index].viewDate.toDate()
                    var nowDate = Date.now
                    nowDate.addTimeInterval(3600 * 9)
                    let viewTime = nowDate.timeIntervalSince(viewDate ?? Date.now)
                    viewCount.views[index].viewTime = "\(Int(viewTime))"
                  }
                }
            } else {
//              KFImage.url(URL(string: content.thumbnailUrl ?? ""))
//                .placeholder {
//                  Color.black
//                }
//                .resizable()
//                .scaledToFill()
//                .tag(index)
//                .frame(width: proxy.size.width)
//                .padding()
//                .rotationEffect(Angle(degrees: -90))
//                .ignoresSafeArea(.all, edges: .top)
              Color.black
                .tag(index)
                .frame(width: proxy.size.width)
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
            }
          }
        }
        .onReceive(apiViewModel.publisher) { id in
          newId = id
        }
        .id(newId)
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
      }
      .rotationEffect(Angle(degrees: 90))
      .frame(width: proxy.size.height)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(maxWidth: proxy.size.width)
      .onChange(of: mainOpacity) { newValue in
        if apiViewModel.mainFeed.isEmpty, players.isEmpty {
          return
        }
        if players.count <= currentIndex {
          return
        }
        guard let player = players[currentIndex] else {
          return
        }
        if newValue == 1 {
          if !isRootStacked {
            if !BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentIndex].userId ?? 0) {
              player.play()
            }
          }
        } else {
          player.pause()
          apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
            var tempSet: Set<Int> = []
            for view in viewCountList {
              tempSet.insert(view.contentId)
            }
            processedContentId = processedContentId.union(tempSet)
          }
        }
      }
      .overlay {
        if showGuide {
          VStack {
            Spacer()
            Button {
              showGuide = false
            } label: {
              Text("닫기")
                .fontSystem(fontDesignSystem: .subtitle2_KO)
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .frame(width: UIScreen.width - 32, height: 56)
                .background {
                  glassMorphicView(cornerRadius: 12)
                    .overlay {
                      RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(
                          LinearGradient.Border_Glass)
                    }
                }
            }
            .padding(.bottom, 32)
          }
          .frame(width: UIScreen.width, height: UIScreen.height)
          .ignoresSafeArea()
          .ignoresSafeArea(.all, edges: .top)
          .background {
            Color.clear.overlay {
              Image("gestureGuide")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .ignoresSafeArea(.all, edges: .top)
            }
            .ignoresSafeArea()
            .ignoresSafeArea(.all, edges: .top)
          }
        }
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
                  .fontSystem(fontDesignSystem: .body2_KO)
              }
            }
            .padding(.top, 70)
            .padding(.leading, 16)
            .onDisappear {
              DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                toastViewModel.toastInit(message: "영상이 게시되었습니다.")
              }
            }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .alert(isPresented: $showUpdate) {
      Alert(
        title: Text("업데이트 알림"),
        message: Text("Whistle의 새로운 버전이 있습니다. 최신 버전으로 업데이트 해주세요."),
        dismissButton: .default(Text("업데이트"), action: {
          guard let url = URL(string: "itms-apps://itunes.apple.com/app/6463850354") else { return }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }))
    }
    .task {
      let updateAvailable = await apiViewModel.checkUpdateAvailable()
      if updateAvailable {
        await apiViewModel.requestVersionCheck()
        showUpdate = apiViewModel.versionCheck.forceUpdate
        if showUpdate {
          return
        }
      }
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.mainFeed.isEmpty {
        if universalRoutingModel.isUniversalContent {
          apiViewModel.requestUniversalFeed(contentID: universalRoutingModel.contentId) {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        } else {
          apiViewModel.requestMainFeed {
            setupPlayers()
          }
        }
      }
    }
    .onChange(of: refreshCount) { _ in
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      setupPlayers()
      apiViewModel.postFeedPlayerChanged()
    }
    .onChange(of: currentIndex) { newValue in
      if universalRoutingModel.isUniversalContent {
        return
      }
      guard let url = apiViewModel.mainFeed[newValue].videoUrl else {
        return
      }
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[newValue]?.seek(to: .zero)
      if !BlockList.shared.userIds.contains(apiViewModel.mainFeed[newValue].userId ?? 0) {
        players[newValue]?.play()
      }
      playerIndex = newValue
      currentVideoUserId = apiViewModel.mainFeed[newValue].userId ?? 0
      currentVideoContentId = apiViewModel.mainFeed[newValue].contentId ?? 0
      currentVideoIsBookmarked = apiViewModel.mainFeed[newValue].isBookmarked ?? false
      apiViewModel.postFeedPlayerChanged()
    }
    .onChange(of: scenePhase) { newValue in
      switch newValue {
      case .background:
        apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
          var tempSet: Set<Int> = []
          for view in viewCountList {
            tempSet.insert(view.contentId)
          }
          processedContentId = processedContentId.union(tempSet)
        }
      default:
        break
      }
    }
    .onChange(of: universalRoutingModel.isUniversalProfile) { newValue in
      if newValue {
        tabbarModel.tabSelectionNoAnimation = .main
        tabbarModel.tabSelection = .main
        isRootStacked = true
      }
    }
    .onChange(of: universalRoutingModel.isUniversalContent) { newValue in
      if newValue, !apiViewModel.mainFeed.isEmpty {
        tabbarModel.tabSelectionNoAnimation = .main
        tabbarModel.tabSelection = .main
        currentIndex = 0
        playerIndex = 0
        currentVideoUserId = 0
        currentVideoContentId = 0
        players.removeAll()
        apiViewModel.mainFeed.removeAll()
        if universalRoutingModel.isUniversalContent {
          apiViewModel.requestUniversalFeed(contentID: universalRoutingModel.contentId) {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        } else {
          apiViewModel.requestMainFeed {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        }
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
        withAnimation {
          isSplashOn = false
        }
      }
    }
    .overlay {
      if isSplashOn {
        SignInPlayer()
          .ignoresSafeArea()
          .allowsTightening(false)
          .onAppear {
            tabbarModel.tabbarOpacity = 0.0
          }
          .onDisappear {
            tabbarModel.tabbarOpacity = 1.0
          }
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button(
        currentVideoIsBookmarked ? "저장 취소" : "저장하기",
        role: .none)
      {
        Task {
          if apiViewModel.mainFeed[currentIndex].isBookmarked ?? false {
            let tempBool = await apiViewModel.bookmarkAction(contentID: currentVideoContentId, method: .delete)
            toastViewModel.toastInit(message: "저장 취소했습니다.")
            apiViewModel.mainFeed[currentIndex].isBookmarked = false
            currentVideoIsBookmarked = false
          } else {
            let tempBool = await apiViewModel.bookmarkAction(contentID: currentVideoContentId, method: .post)
            toastViewModel.toastInit(message: "저장했습니다.")
            apiViewModel.mainFeed[currentIndex].isBookmarked = true
            currentVideoIsBookmarked = true
          }
          apiViewModel.postFeedPlayerChanged()
        }
      }
      Button("관심없음", role: .none) {
        toastViewModel.cancelToastInit(message: "해당 콘텐츠를 숨겼습니다") {
          Task {
            await apiViewModel.actionContentHate(contentID: currentVideoContentId)
            apiViewModel.mainFeed.remove(at: currentIndex)
            guard let url = apiViewModel.mainFeed[currentIndex].videoUrl else {
              return
            }
            players[currentIndex] = AVPlayer(url: URL(string: url)!)
            await players[currentIndex]?.seek(to: .zero)
            players[currentIndex]?.play()
            apiViewModel.postFeedPlayerChanged()
          }
        }
      }
      if currentVideoUserId != apiViewModel.myProfile.userId {
        Button("신고", role: .destructive) {
          showReport = true
        }
      }
      Button("닫기", role: .cancel) { }
    }
    .fullScreenCover(isPresented: $showReport) {
      MainFeedReportReasonSelectionView(
        goReport: $showReport,
        contentId: currentVideoContentId,
        userId: currentVideoUserId)
    }
    .navigationDestination(isPresented: $isRootStacked) {
      if universalRoutingModel.isUniversalProfile {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEMemberProfileView(players: $players, currentIndex: $currentIndex, userId: universalRoutingModel.userId)

              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          default:
            MemberProfileView(players: $players, currentIndex: $currentIndex, userId: universalRoutingModel.userId)

              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          }
        }
      } else {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEMemberProfileView(players: $players, currentIndex: $currentIndex, userId: currentVideoUserId)

          default:
            MemberProfileView(players: $players, currentIndex: $currentIndex, userId: currentVideoUserId)
          }
        }
      }
    }
  }
}

extension MainFeedView {
  @ViewBuilder
  func userInfo(
    contentId _: Int,
    userName: String,
    profileImg: String,
    isFollowed: Binding<Bool>,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    whistleCount: Binding<Int>)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            if apiViewModel.mainFeed[currentIndex].userName != apiViewModel.myProfile.userName {
              Button {
                isRootStacked = true
              } label: {
                Group {
                  profileImageView(url: profileImg, size: 36)
                    .padding(.trailing, UIScreen.getWidth(8))
                  Text(userName)
                    .foregroundColor(.white)
                    .fontSystem(fontDesignSystem: .subtitle1)
                    .padding(.trailing, 16)
                }
              }
            } else {
              Group {
                profileImageView(url: profileImg, size: 36)
                  .padding(.trailing, 12)
                Text(userName)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .subtitle1)
                  .padding(.trailing, 16)
              }
            }
            if userName != apiViewModel.myProfile.userName {
              Button {
                Task {
                  if isFollowed.wrappedValue {
                    await apiViewModel.followAction(userID: currentVideoUserId, method: .delete)
                    toastViewModel.toastInit(message: "\(userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followAction(userID: currentVideoUserId, method: .post)
                    toastViewModel.toastInit(message: "\(userName)님을 팔로우 중")
                  }
                  isFollowed.wrappedValue.toggle()
                  apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
                    let mutableItem = item
                    if mutableItem.userId == currentVideoUserId {
                      mutableItem.isFollowed = isFollowed.wrappedValue
                    }
                    return mutableItem
                  }
                  apiViewModel.postFeedPlayerChanged()
                }
              } label: {
                Text(isFollowed.wrappedValue ? "팔로잉" : "팔로우")
                  .fontSystem(fontDesignSystem: .caption_KO_Semibold)
                  .foregroundColor(.Gray10)
                  .background {
                    Capsule()
                      .stroke(Color.Gray10, lineWidth: 1)
                      .frame(width: 58, height: 26)
                  }
                  .frame(width: 58, height: 26)
              }
            }
          }
          if !caption.isEmpty {
            HStack(spacing: 0) {
              Text(caption)
                .fontSystem(fontDesignSystem: .body2_KO)
                .foregroundColor(.white)
            }
          }
          Label(musicTitle, systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
            .padding(.top, 4)
        }
        .padding(.bottom, 4)
        .padding(.leading, 4)
        Spacer()
        VStack(spacing: 28) {
          Spacer()
          Button {
            whistleToggle()
          } label: {
            VStack(spacing: 0) {
              Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .frame(width: 36, height: 36)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .subtitle3_KO)
            }
            .padding(.bottom, -4)
          }
          Button {
            toastViewModel.toastInit(message: "클립보드에 복사되었어요")
            UIPasteboard.general.setValue(
              "https://readywhistle.com/content_uni?contentId=\(currentVideoContentId)",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
        }
      }
    }
    .padding(.bottom, UIScreen.getHeight(48))
    .padding(.trailing, UIScreen.getWidth(12))
    .padding(.leading, UIScreen.getWidth(16))
  }
}

// MARK: - Timer

extension MainFeedView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.mainFeed[currentIndex].isWhistled {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: currentVideoContentId, method: .delete)
        }
      }
      apiViewModel.mainFeed[currentIndex].whistleCount -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: currentVideoContentId, method: .post)
        }
      }
      apiViewModel.mainFeed[currentIndex].whistleCount += 1
    }
    apiViewModel.mainFeed[currentIndex].isWhistled.toggle()
    apiViewModel.postFeedPlayerChanged()
  }
}

extension String {
  func toDate() -> Date? { // "yyyy-MM-dd HH:mm:ss"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let date = dateFormatter.date(from: self) {
      return date
    } else {
      return nil
    }
  }
}

extension Date {
  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: self)
  }
}

extension MainFeedView {
  func setupPlayers() {
    Task {
      if !apiViewModel.mainFeed.isEmpty {
        players.removeAll()
        for _ in 0 ..< apiViewModel.mainFeed.count {
          players.append(nil)
        }
        players[currentIndex] =
          AVPlayer(url: URL(string: apiViewModel.mainFeed[currentIndex].videoUrl ?? "")!)
        playerIndex = currentIndex
        guard let player = players[currentIndex] else {
          return
        }
        currentVideoUserId = apiViewModel.mainFeed[currentIndex].userId ?? 0
        currentVideoContentId = apiViewModel.mainFeed[currentIndex].contentId ?? 0
        isCurrentVideoWhistled = apiViewModel.mainFeed[currentIndex].isWhistled
        currentVideoIsBookmarked = apiViewModel.mainFeed[currentIndex].isBookmarked
        await player.seek(to: .zero)
        if !BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentIndex].userId ?? 0) {
          player.play()
        }
        withAnimation {
          isSplashOn = false
        }
        if universalRoutingModel.isUniversalProfile {
          isRootStacked = true
        }
      }
    }
  }
}
