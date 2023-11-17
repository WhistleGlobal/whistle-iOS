//
//  TabbarModel.swift
//  Whistle
//
//  Created by 박상원 on 10/23/23.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - TabbarModel

class TabbarModel: ObservableObject {
  static let shared = TabbarModel()
  private init() { }
  
  @Published var tabSelection: TabSelection = .main
  @Published var tabbarOpacity = 1.0
  @Published var tabWidth = UIScreen.width - 32
  @Published var showVideoCaptureView = false

  private let collapseWidth: CGFloat = 56
  private let expandedWidth = UIScreen.width - 32

  func switchTab(to tabSelection: TabSelection) {
    self.tabSelection = tabSelection
  }

  func hideTabbar() {
    tabbarOpacity = 0.0
  }

  func showTabbar() {
    tabbarOpacity = 1.0
  }

  func collapse() {
    withAnimation {
      tabWidth = collapseWidth
    }
  }

  func expand() {
    withAnimation {
      tabWidth = expandedWidth
    }
  }

  func isCollpased() -> Bool {
    if tabWidth == collapseWidth {
      return true
    } else {
      return false
    }
  }
}
