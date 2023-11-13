//
//  BottomSheetView.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import SwiftUI

struct BottomSheetView<HContent: View, MContent: View>: View {

  // For iPhone landscape and iPad support
  #if !os(macOS)
//  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
  @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
  #endif

  @Binding var bottomSheetPosition: BottomSheetPosition
  @State var translation: CGFloat = 0

  #if !os(macOS)
  // For `appleScrollBehaviour`
  @State var isScrollEnabled = false
  @State var dragState: DragGesture.DragState = .none
  #endif

  // View heights
  @State var headerContentHeight: CGFloat = 0
  @State var dynamicMainContentHeight: CGFloat = 0

  #if !os(macOS)
  @ObservedObject var keyboardHeight = KeyboardHeight()
  #endif

  // Views
  let headerContent: HContent?
  let mainContent: MContent

  let switchablePositions: [BottomSheetPosition]

  // Configuration
  let configuration: BottomSheetConfiguration

  var body: some View {
    // GeometryReader for size calculations
    GeometryReader { geometry in
      // ZStack for aligning content
      ZStack(
        // On iPad floating and Mac the BottomSheet is aligned to the top left
        // On iPhone and iPad not floating it is aligned to the bottom center,
        // in horizontal mode to the bottom left
        alignment: isIPadFloatingOrMac ? .topLeading : .bottomLeading)
      {
        // Hide everything when the BottomSheet is hidden
        if !bottomSheetPosition.isHidden {
          // Full screen background for aligning and used by `backgroundBlur` and `tapToDismiss`
          fullScreenBackground(with: geometry)

          // The BottomSheet itself
          bottomSheet(with: geometry)
        }
      }
      // Animate value changes
      #if !os(macOS)
//      .animation(
//        configuration.animation,
//        value: horizontalSizeClass)
      .animation(
        configuration.animation,
        value: verticalSizeClass)
      #endif
        .animation(
          configuration.animation,
          value: bottomSheetPosition)
        .animation(
          configuration.animation,
          value: translation)
      #if !os(macOS)
        .animation(
          configuration.animation,
          value: isScrollEnabled)
        .animation(
          configuration.animation,
          value: dragState)
      #endif
        .animation(
          configuration.animation,
          value: headerContentHeight)
        .animation(
          configuration.animation,
          value: dynamicMainContentHeight)
        .animation(
          configuration.animation,
          value: configuration)
    }
    // Make the GeometryReader ignore specific safe area (for transition to work)
    // On iPhone and iPad not floating ignore bottom safe area, because the BottomSheet moves to the bottom edge
    // On iPad floating and Mac ignore top safe area, because the BottomSheet moves to the top edge
    .ignoresSafeAreaCompatible(
      .container,
      edges: isIPadFloatingOrMac ? .top : .bottom)
  }
}
