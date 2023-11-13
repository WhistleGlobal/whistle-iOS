//
//  BottomSheet+Threshold.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// Sets a custom threshold which determines, when to trigger swipe to dismiss or flick through.
  ///
  /// The threshold must be positive and higher than 10% (0.1).
  /// Changing the threshold does not affect whether either option is enabled.
  /// The default threshold is 30% (0.3)
  ///
  /// - Parameters:
  ///   - threshold: The threshold as percentage of the screen height.
  ///
  /// - Returns: A BottomSheet with a custom threshold.
  public func customThreshold(_ threshold: Double) -> BottomSheet {
    configuration.threshold = threshold
    return self
  }
}
