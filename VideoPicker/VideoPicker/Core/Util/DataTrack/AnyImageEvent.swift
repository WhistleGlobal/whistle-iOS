//
//  AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

// MARK: - AnyImageEvent

public struct AnyImageEvent: Equatable, RawRepresentable {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: ExpressibleByStringLiteral

extension AnyImageEvent: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    rawValue = value
  }
}

// MARK: - AnyImageEventUserInfoKey

public struct AnyImageEventUserInfoKey: Hashable, RawRepresentable {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: ExpressibleByStringLiteral

extension AnyImageEventUserInfoKey: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    rawValue = value
  }
}

extension AnyImageEventUserInfoKey {

  /// Value: Bool
  public static let isOn: AnyImageEventUserInfoKey = "ANYIMAGEKIT_USERINFO_IS_ON"

  /// Value: AnyImagePage
  public static let page: AnyImageEventUserInfoKey = "ANYIMAGEKIT_USERINFO_PAGE"
}
