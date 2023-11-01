//
//  MemberFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/31/23.
//

import _AVKit_SwiftUI
import BottomSheet
import SwiftUI

// MARK: - MemberFeedView

struct MemberFeedView: View {

  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = MemeberPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = MemberFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
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
          Text(ContentWords().noBookmarkedContent)
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
      switchablePositions: [.hidden, .absolute(242)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text(CommonWords().more)
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.white)
          Spacer()
          Button {
            feedMoreModel.bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
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
          toastViewModel.cancelToastInit(message: ToastMessages().postHidden) {
            Task {
              let currentContent = apiViewModel.memberFeed[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0)
              feedPlayersViewModel.removePlayer {
                index -= 1
              }
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "eye.fill", text: CommonWords().hide)
        }
        Button {
          feedMoreModel.bottomSheetPosition = .hidden
          feedPlayersViewModel.stopPlayer()
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
  @Published var showReport = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}
