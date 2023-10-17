//
//  ToolButtonView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - ToolButtonView

struct ToolButtonView: View {
  let label: String
  let image: String
  let isChange: Bool
  let action: () -> Void

  //  private var bgColor: Color {
  ////    Color(isChange ? .systemGray5 : .systemGray6)
  //  }

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
      ToolButtonView(label: "Cut", image: "scissors", isChange: false) { }
      ToolButtonView(label: "Cut", image: "scissors", isChange: true) { }
    }
    .frame(width: 100)
  }
}
