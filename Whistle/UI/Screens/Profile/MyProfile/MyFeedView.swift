//
//  MyFeedKitView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import _AVKit_SwiftUI
import SwiftUI

// MARK: - MyFeedView

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
        Button(CommonWords().delete, role: .destructive) {
          toastViewModel.cancelToastInit(message: ToastMessages().contentDeleted) {
            Task {
              let currentContent = apiViewModel.myFeed[feedPlayersViewModel.currentVideoIndex]
              await apiViewModel.deleteContent(contentID: currentContent.contentId ?? 0)
              feedPlayersViewModel.removePlayer {
                index -= 1
              }
            }
          }
        }
        Button(CommonWords().close, role: .cancel) { }
      }
    }
    .task {
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.myFeed.isEmpty {
        await apiViewModel.requestMyPostFeed()
      }
    }
  }
}

// MARK: - MyFeedMoreModel

class MyFeedMoreModel: ObservableObject {
  static let shared = MyFeedMoreModel()
  private init() { }
  @Published var showDialog = false
}
