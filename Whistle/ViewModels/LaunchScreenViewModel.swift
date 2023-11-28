//
//  LaunchScreenViewModel.swift
//  Whistle
//
//  Created by 박상원 on 11/21/23.
//

import Foundation

class LaunchScreenViewModel: ObservableObject {
  static let shared = LaunchScreenViewModel()

  private init() { }

  @Published var isFeedDownloded = false
  @Published var isMyTeamFeedDownloded = false
  @Published var isContentPlayerReady = false
  @Published var myTeamContentLoaded = false
  var displayLaunchScreen: Bool {
    if APIViewModel.shared.myProfile.myTeam == nil {
      isFeedDownloded && isContentPlayerReady ? false : true
    } else {
      isFeedDownloded && isContentPlayerReady && myTeamContentLoaded && isMyTeamFeedDownloded ? false : true
    }
  }

  func feedDownloaded() {
    isFeedDownloded = true
  }

  func myTeamFeedDownloaded() {
    isMyTeamFeedDownloded = true
  }

  func contentPlayerReady() {
    isContentPlayerReady = true
  }

  func myTeamContentPlayerReady() {
    myTeamContentLoaded = true
  }
}
