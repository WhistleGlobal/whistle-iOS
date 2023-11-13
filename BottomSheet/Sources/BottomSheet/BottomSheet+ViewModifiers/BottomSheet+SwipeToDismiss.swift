//
//  BottomSheet+SwipeToDismiss.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// Makes it possible to dismiss the BottomSheet by long swiping.
  ///
  /// - Parameters:
  ///   - bool: A boolean whether the option is enabled.
  ///
  /// - Returns: A BottomSheet that can be dismissed by long swiping.
  public func enableSwipeToDismiss(_ bool: Bool = true) -> BottomSheet {
    configuration.isSwipeToDismissEnabled = bool
    return self
  }
}
