//
//  BottomSheet+FloatingIPadSheet.swift
//
//  Created by Robin Pel.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// Makes it possible to make the sheet appear like on iPhone.
  ///
  /// - Parameters:
  ///   - bool: A boolean whether the option is enabled.
  ///
  /// - Returns: A BottomSheet that will actually appear at the bottom.
  public func enableFloatingIPadSheet(_ bool: Bool = true) -> BottomSheet {
    configuration.iPadFloatingSheet = bool
    return self
  }
}
