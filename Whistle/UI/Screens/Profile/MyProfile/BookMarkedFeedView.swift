//
//  BookmarkedFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import _AVKit_SwiftUI
import BottomSheet
import SwiftUI

// MARK: - BookMarkedFeedView

struct BookMarkedFeedView: View {

  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = BookmarkedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = BookmarkedFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
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
    .bottomSheet(
      bottomSheetPosition: $feedMoreModel.bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(186)])
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
//        Button {
//          feedMoreModel.bottomSheetPosition = .hidden
//          toastViewModel.cancelToastInit(message: "해당 콘텐츠를 숨겼습니다") {
//            Task {
//              let currentContent = apiViewModel.mainFeed[feedPlayersViewModel.currentVideoIndex]
//              await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0)
//              feedPlayersViewModel.removePlayer {
//                index -= 1
//              }
//            }
//          }
//        } label: {
//          bottomSheetRowWithIcon(systemName: "eye.fill", text: "관심없음")
//        }
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          feedPlayersViewModel.stopPlayer()
          feedMoreModel.showReport = true
        } label: {
          bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: "신고하기")
        }

        Spacer()
      }
      .frame(height: 186)
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
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      feedPlayersViewModel.currentPlayer?.play()
    }) {
      MainFeedReportReasonSelectionView(
        goReport: $feedMoreModel.showReport,
        contentId: apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].contentId,
        userId: apiViewModel.bookmark[feedPlayersViewModel.currentVideoIndex].userId)
    }
  }
}

// MARK: - BookmarkedFeedMoreModel

class BookmarkedFeedMoreModel: ObservableObject {
  static let shared = BookmarkedFeedMoreModel()
  private init() { }
  @Published var showReport = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}
