//
//  ToolButtonView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - EditorToolButton

struct EditorToolButton: View {
  let label: LocalizedStringKey
  let image: String
  let isChange: Bool
  let action: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color("Gray30_Dark").opacity(0.24))
        VStack(spacing: 6) {
          Image(systemName: image)
            .font(.system(size: 20))
          Text(label)
            .fontSystem(fontDesignSystem: .body2_KO)
        }
        .hCenter()
      }
      .frame(width: UIScreen.getWidth(107), height: UIScreen.getHeight(72))
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(LinearGradient.Border_Glass, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .foregroundStyle(Color.white)
  }
}

// MARK: - ToolButtonView_Previews

struct ToolButtonView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      EditorToolButton(label: "Cut", image: "scissors", isChange: false) { }
      EditorToolButton(label: "Cut", image: "scissors", isChange: true) { }
    }
    .frame(width: 100)
  }
}
