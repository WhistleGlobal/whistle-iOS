//
//  BottomSheetTestView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/7/23.
//

import BottomSheet
import ReverseMask
import SwiftUI

// MARK: - BottomSheetTestView

// struct BottomSheetTestView: View {
//
//  @State var bottomSheetPosition: BottomSheetPosition = .absolute(406)
//  @State var selectedSec: SelectedSecond = .sec3
//  @State var dragOffset: CGFloat = 0
//  var barSpacing: CGFloat {
//    CGFloat((UIScreen.width - 32 - 12 - (14 * 6)) / 15)
//  }
//
//  var defaultWidth: CGFloat {
//    CGFloat(6 + (6 + barSpacing) * 8)
//  }
//
//  var body: some View {
//    VStack {
//      Color.clear
//    }
//    .onChange(of: dragOffset, perform: { _ in
//      log(dragOffset)
//    })
//  }
// }
//
//// MARK: - SelectedSecond
//
// enum SelectedSecond: Int {
//  case sec3 = -1
//  case sec10 = 1
// }
