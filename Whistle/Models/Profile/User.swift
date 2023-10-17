//
//  User.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class User: ObservableObject, Codable, Hashable {
  var uuid = UUID()
  var userId = 0
  var userName = ""
  var email = ""
  var profileImg = ""
  var introduce: String?
  var country: String?
  var createdAt = Date()
  var status: UserStatus = .active
  var quitAt: Date?

  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: User, rhs: User) -> Bool {
    lhs.uuid == rhs.uuid
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
