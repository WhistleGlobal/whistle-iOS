//
//  MainFeedTabModel.swift
//  Whistle
//
//  Created by 박상원 on 11/23/23.
//

import Foundation

// MARK: - MainFeedTabSelection

enum MainFeedTabSelection: Identifiable {
  case all
  case myteam

  var id: MainFeedTabSelection {
    self
  }
}

// MARK: - MainFeedTabModel

class MainFeedTabModel: ObservableObject {
  static let shared = MainFeedTabModel()
  private init() { }

  @Published private var tabSelection: MainFeedTabSelection = .all

  var isMyTeamTab: Bool {
    tabSelection == .myteam
  }

  var isAllTab: Bool {
    tabSelection == .all
  }

  func switchTab(to tabSelection: MainFeedTabSelection) {
    self.tabSelection = tabSelection
  }
}
