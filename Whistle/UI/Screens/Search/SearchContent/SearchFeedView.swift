//
//  SearchFeedView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import _AVKit_SwiftUI
import BottomSheet
import SwiftUI

// MARK: - SearchFeedView

struct SearchFeedView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var feedPlayersViewModel = SearchPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = SearchFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @State var index = 0
  let userId: Int

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.searchedContent.isEmpty {
        SearchFeedPageView(index: $index, dismissAction: dismiss)
          .toolbarRole(.editor)
      } else {
        VStack {
          Spacer()
          Image(systemName: "photo.fill")
            .font(.system(size: 44, weight: .light))
            .foregroundColor(.LabelColor_Primary_Dark)
          Text(ContentWords().noConent)
            .fontSystem(fontDesignSystem: .subtitle1)
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
              let currentContent = apiViewModel.searchedContent[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.actionContentHate(contentID: currentContent.contentId ?? 0, method: .post)
              feedPlayersViewModel.removePlayer {
                index -= 1
              }
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "eye.slash.fill", text: CommonWords().hide)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
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
    .navigationDestination(isPresented: $feedMoreModel.isRootStacked) {
      if !apiViewModel.searchedContent.isEmpty {
        ProfileView(
          profileType:
          apiViewModel.searchedContent[feedPlayersViewModel.currentVideoIndex].userId ?? 0 == apiViewModel.myProfile.userId
            ? .my
            : .member,
          isFirstProfileLoaded: .constant(true),
          userId: apiViewModel.searchedContent[feedPlayersViewModel.currentVideoIndex].userId ?? 0)
      }
    }
    .fullScreenCover(isPresented: $feedMoreModel.showReport, onDismiss: {
      feedPlayersViewModel.currentPlayer?.play()
    }) {
      MainFeedReportReasonSelectionView(
        goReport: $feedMoreModel.showReport,
        contentId: apiViewModel.searchedContent[feedPlayersViewModel.currentVideoIndex].contentId ?? 0,
        userId: userId)
    }
  }
}

// MARK: - SearchFeedMoreModel

class SearchFeedMoreModel: ObservableObject {
  static let shared = SearchFeedMoreModel()
  private init() { }
  @Published var showReport = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}
