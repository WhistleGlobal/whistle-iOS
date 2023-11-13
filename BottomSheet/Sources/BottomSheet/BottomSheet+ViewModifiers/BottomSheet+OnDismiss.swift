//
//  BottomSheet+OnDismiss.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import Foundation

extension BottomSheet {

  /// A action that will be performed when the BottomSheet is dismissed.
  ///
  /// Please note that when you dismiss the BottomSheet yourself, by setting the bottomSheetPosition to .hidden,
  /// the action will not be called.
  ///
  /// - Parameters:
  ///   - perform: The action to perform when the BottomSheet is dismissed.
  ///
  /// - Returns: A BottomSheet with a custom on dismiss action.
  public func onDismiss(_ perform: @escaping () -> Void) -> BottomSheet {
    configuration.onDismiss = perform
    return self
  }
}
