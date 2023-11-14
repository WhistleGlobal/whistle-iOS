//
//  BottomSheet+CustomAnimation.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import SwiftUI

extension BottomSheet {

  /// Applies the given animation to the BottomSheet when any value changes.
  ///
  /// - Parameters:
  ///   - animation: The animation to apply. If animation is nil, the view doesn’t animate.
  ///
  /// - Returns: A view that applies `animation` to the BottomSheet.
  public func customAnimation(_ animation: Animation?) -> BottomSheet {
    configuration.animation = animation
    return self
  }
}
