//
//  TabSelectionModel.swift
//  Whistle
//
//  Created by 박상원 on 11/16/23.
//

import SwiftUI

// MARK: - Tab

enum Tab: String {
  case main
  case profile
}

// MARK: - TabSelectionModel

class TabSelectionModel: ObservableObject {
  static let shared = TabSelectionModel()
  private init() { }
  @Published var currentTab: Tab = .main

  func switchTab(to tabSelection: Tab) {
    currentTab = tabSelection
  }
}
