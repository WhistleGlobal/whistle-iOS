//
//  BottomSheet+TapToDismiss.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// Makes it possible to dismiss the BottomSheet by tapping somewhere else.
  ///
  /// - Parameters:
  ///   - bool: A boolean whether the option is enabled.
  ///
  /// - Returns: A BottomSheet that can be dismissed by tapping somewhere else.
  public func enableTapToDismiss(_ bool: Bool = true) -> BottomSheet {
    configuration.isTapToDismissEnabled = bool
    return self
  }
}
