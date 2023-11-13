//
//  BottomSheetConfiguration.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import SwiftUI

class BottomSheetConfiguration: Equatable {
  // For animating changes
  static func == (
    lhs: BottomSheetConfiguration,
    rhs: BottomSheetConfiguration)
    -> Bool
  {
    lhs.animation == rhs.animation &&
      lhs.backgroundBlurMaterial == rhs.backgroundBlurMaterial &&
      lhs.backgroundViewID == rhs.backgroundViewID &&
      lhs.dragIndicatorColor == rhs.dragIndicatorColor &&
      lhs.isAppleScrollBehaviorEnabled == rhs.isAppleScrollBehaviorEnabled &&
      lhs.isBackgroundBlurEnabled == rhs.isBackgroundBlurEnabled &&
      lhs.isCloseButtonShown == rhs.isCloseButtonShown &&
      lhs.isContentDragEnabled == rhs.isContentDragEnabled &&
      lhs.isDragIndicatorShown == rhs.isDragIndicatorShown &&
      lhs.isFlickThroughEnabled == rhs.isFlickThroughEnabled &&
      lhs.isResizable == rhs.isResizable &&
      lhs.isSwipeToDismissEnabled == rhs.isSwipeToDismissEnabled &&
      lhs.isTapToDismissEnabled == rhs.isTapToDismissEnabled &&
      lhs.iPadFloatingSheet == rhs.iPadFloatingSheet &&
      lhs.sheetWidth == rhs.sheetWidth &&
      lhs.accountForKeyboardHeight == rhs.accountForKeyboardHeight
  }

  var animation: Animation? = .easeInOut(duration: 0.2)
//    .spring(
//        response: 0.5,
//        dampingFraction: 0.75,
//        blendDuration: 1
//    )
  var backgroundBlurMaterial: VisualEffect = .system
  var backgroundViewID: UUID?
  var backgroundView: AnyView?
  var dragIndicatorAction: ((GeometryProxy) -> Void)?
  var dragIndicatorColor = Color.tertiaryLabel
  var dragPositionSwitchAction: ((
    GeometryProxy,
    DragGesture.Value) -> Void)?
  var isAppleScrollBehaviorEnabled = false
  var isBackgroundBlurEnabled = false
  var isCloseButtonShown = false
  var isContentDragEnabled = false
  var isDragIndicatorShown = true
  var isFlickThroughEnabled = true
  var isResizable = true
  var isSwipeToDismissEnabled = false
  var isTapToDismissEnabled = false
  var onDismiss: () -> Void = { }
  var onDragEnded: (DragGesture.Value) -> Void = { _ in }
  var onDragChanged: (DragGesture.Value) -> Void = { _ in }
  var threshold = 0.1
  var iPadFloatingSheet = true
  var sheetWidth: BottomSheetWidth = .platformDefault
  var accountForKeyboardHeight = false
}
