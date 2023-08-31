//
//  UserResponse.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import SwiftUI

struct UserResponse: Decodable {
  var email: String
  var user_name: String?
  var profile_img: String?
}

