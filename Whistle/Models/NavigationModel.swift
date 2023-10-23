//
//  NavigationModel.swift
//  Whistle
//
//  Created by 박상원 on 10/23/23.
//

import Foundation

// MARK: - NavigationModel

class NavigationModel: ObservableObject {
  static var shared = NavigationModel()
  private init() { }

  @Published var navigate = false
}
