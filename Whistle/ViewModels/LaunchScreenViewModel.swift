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

  @Published var isMainFeedDownloded = false
  @Published var isMainContentPlayerReady = false
  var displayLaunchScreen: Bool {
    isMainFeedDownloded && isMainContentPlayerReady ? false : true
  }

  func mainFeedDownloaded() {
    isMainFeedDownloded = true
  }

  func mainContentPlayerReady() {
    isMainContentPlayerReady = true
  }
}
