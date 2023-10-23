//
//  TabbarModel.swift
//  Whistle
//
//  Created by 박상원 on 10/23/23.
//

import Foundation
import UIKit

// MARK: - TabbarModel

class TabbarModel: ObservableObject {

  static let shared = TabbarModel()
  private init() { }

  @Published var tabSelection: TabSelection = .main
  @Published var tabSelectionNoAnimation: TabSelection = .main
  @Published var prevTabSelection: TabSelection?
  @Published var tabbarOpacity = 1.0
  @Published var tabWidth = UIScreen.width - 32
}
