//
//  TabSelectionModel.swift
//  Whistle
//
//  Created by 박상원 on 11/16/23.
//

import SwiftUI

enum Tab {
  case main, profile
}

class TabSelectionModel: ObservableObject {
  static let shared = TabSelectionModel()
  private init() {}
  @Published var currentTab: Tab = .main
}
