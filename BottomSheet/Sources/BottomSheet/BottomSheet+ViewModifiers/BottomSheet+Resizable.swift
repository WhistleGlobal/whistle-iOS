//
//  BottomSheet+Resizable.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// Makes it possible to resize the BottomSheet.
  ///
  /// When disabled the drag indicator disappears.
  ///
  /// - Parameters:
  ///   - bool: A boolean whether the option is enabled.
  ///
  /// - Returns: A BottomSheet that can be resized.
  public func isResizable(_ bool: Bool = true) -> BottomSheet {
    configuration.isResizable = bool
    return self
  }
}
