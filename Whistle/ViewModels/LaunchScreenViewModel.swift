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
  @Published var isContentPlayerReady = false
  var displayLaunchScreen: Bool {
    isFeedDownloded && isContentPlayerReady ? false : true
  }

  func feedDownloaded() {
    isFeedDownloded = true
  }

  func contentPlayerReady() {
    isContentPlayerReady = true
  }
}
