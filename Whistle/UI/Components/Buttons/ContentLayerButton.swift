//
//  ContentLayerButton.swift
//  Whistle
//
//  Created by 박상원 on 11/1/23.
//

import SwiftUI

struct ContentLayerButton: View {
  let buttonType: ContentLayerButtonType
  @Binding var isFilled: Bool

  init(
    type: ContentLayerButtonType,
    isFilled: Binding<Bool> = .constant(false))
  {
    buttonType = type
    _isFilled = isFilled
  }

  var body: some View {
    VStack(spacing: 2) {
      switch buttonType {
      case .whistle:
        Image(isFilled ? "whistleIconFill" : "whistleIcon")
          .resizable()
          .scaledToFit()
          .shadow(color: isFilled ? .black.opacity(0.15) : .black.opacity(0.3), radius: 4, x: 0, y: 0)
          .frame(width: 36, height: 36)
      case .bookmark:
        Image(systemName: isFilled ? buttonType.filledSymbol : buttonType.defaultSymbol)
          .font(.system(size: 26))
          .shadow(color: isFilled ? .black.opacity(0.15) : .black.opacity(0.3), radius: 4, x: 0, y: 0)
          .frame(width: 36, height: 36)
      case .share, .more:
        Image(systemName: buttonType.defaultSymbol)
          .font(.system(size: 26))
          .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
          .frame(width: 36, height: 36)
      }
      Text(buttonType.buttonLabel)
        .fontSystem(fontDesignSystem: .caption_SemiBold)
        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 0)
    }
    .frame(height: UIScreen.getHeight(56))
    .contentShape(Rectangle())
  }
}
