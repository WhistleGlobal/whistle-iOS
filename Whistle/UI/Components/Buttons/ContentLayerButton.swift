//
//  ContentLayerButton.swift
//  Whistle
//
//  Created by 박상원 on 11/1/23.
//

import SwiftUI

struct ContentLayerButton: View {
  @Binding var isFilled: Bool
  let image: String
  let filledImage: String?
  let label: LocalizedStringKey

  init(isFilled: Binding<Bool> = .constant(false), image: String, filledImage: String? = nil, label: LocalizedStringKey) {
    _isFilled = isFilled
    self.image = image
    self.filledImage = filledImage
    self.label = label
  }

  var body: some View {
    VStack(spacing: 2) {
      if let filledImage {
        Image(systemName: isFilled ? filledImage : image)
          .font(.system(size: 26))
          .shadow(color: isFilled ? .black.opacity(0.15) : .black.opacity(0.3), radius: 4, x: 0, y: 0)
          .frame(width: 36, height: 36)
      } else {
        Image(systemName: image)
          .font(.system(size: 26))
          .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
          .frame(width: 36, height: 36)
      }
      Text(label)
        .fontSystem(fontDesignSystem: .caption_SemiBold)
        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 0)
    }
    .frame(height: UIScreen.getHeight(56))
  }
}
