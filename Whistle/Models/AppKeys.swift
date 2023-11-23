//
//  AppKeys.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import Foundation

enum AppKeys {
  #if DEBUG
  static let domainURL = Bundle.main.object(forInfoDictionaryKey: "DevUrl")
  #else
  static let domainURL = Bundle.main.object(forInfoDictionaryKey: "DomainUrl")
  #endif
}
