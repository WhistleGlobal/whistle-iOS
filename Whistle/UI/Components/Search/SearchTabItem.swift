//
//  SearchTabItemView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/13/23.
//

import Foundation
import SwiftUI

// MARK: - SearchTabItemView

struct SearchTabItem<T>: View where T: RawRepresentable, T.RawValue == LocalizedStringKey {
  @Binding var tabSelected: T
  let tabType: T
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        Spacer()
        Rectangle()
          .foregroundColor(Color.Gray30_Dark)
          .frame(height: 1)
          .overlay {
            Capsule()
              .frame(height: 2)
              .foregroundColor(.labelColorPrimary)
              .opacity(tabType == tabSelected ? 1 : 0)
          }
      }
      Text(tabType.rawValue)
        .fontSystem(fontDesignSystem: .subtitle3)
        .fontWeight(.semibold)
        .foregroundColor(tabType == tabSelected ? Color.labelColorPrimary : Color.labelColorDisablePlaceholder)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onTapGesture {
      tabSelected = tabType
    }
  }
}
