//
//  User.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class User: ObservableObject, Codable {

  var userId = 0
  var userName = ""
  var email = ""
  var profileImg = ""
  var introduce: String?
  var country: String?
  var createdAt = Date()
  var status: UserStatus = .active
  var quitAt: Date?
}
