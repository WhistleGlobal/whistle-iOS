//
//  VersionCheck.swift
//  Whistle
//
//  Created by ChoiYujin on 10/11/23.
//

import Foundation

class VersionCheck: ObservableObject {

  @Published var needUpdate = false
  @Published var reason = ""
  @Published var forceUpdate = false
  @Published var latestAppVersion = ""
}
