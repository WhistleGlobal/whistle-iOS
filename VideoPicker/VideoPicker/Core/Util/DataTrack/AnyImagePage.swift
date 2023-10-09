//
//  AnyImagePage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

// MARK: - AnyImagePage

public struct AnyImagePage: Equatable, RawRepresentable {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: ExpressibleByStringLiteral

extension AnyImagePage: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    rawValue = value
  }
}

extension AnyImagePage {

  static let undefined: AnyImagePage = "ANYIMAGEKIT_PAGE_CORE_UNDEFINED"
}

// MARK: - AnyImagePageState

public enum AnyImagePageState: Equatable {

  case enter
  case leave
}
