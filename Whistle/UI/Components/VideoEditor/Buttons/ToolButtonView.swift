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

  private var bgColor: Color {
    Color(isChange ? .systemGray5 : .systemGray6)
  }

  var body: some View {
    Button {
      action()
    } label: {
      VStack(spacing: 4) {
        Image(systemName: image)
          .imageScale(.medium)
        Text(label)
          .font(.caption)
      }
      .frame(width: 107, height: 85)
      .hCenter()
      .background(bgColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
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
