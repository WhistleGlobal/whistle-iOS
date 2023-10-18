//
//  BlockedUserList.swift
//  Whistle
//
//  Created by ChoiYujin on 10/18/23.
//

import Foundation
import SwiftUI

// MARK: - BlockedUserList

class BlockList: ObservableObject {
  private init() { }
  static let shared = BlockList()
  @Published var userIds: [Int] = []
}
