//
//  VideoSpeedSlider.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - VideoSpeedSlider

struct VideoSpeedSlider: View {
  @State var value: Double = 1
  var isChangeState: Bool?
  let onEditingChanged: (Float) -> Void
  private let rateRange = 0.1 ... 10
  var body: some View {
    VStack {
      Text(String(format: "%.1fx", value))
        .fontSystem(fontDesignSystem: .subtitle2)
        .foregroundStyle(.white)
      UniSlider(
        value: $value,
        in: rateRange,
        step: 0.1,
        minimumValueLabel: Text("0.1x"),
        maximumValueLabel: Text("10x"),
        onEditingChanged: { started in
          if !started {
            onEditingChanged(Float(value))
          }
        },
        track: {
          Capsule()
            .foregroundColor(Color.Border_Default_Dark)
            .frame(width: UIScreen.getWidth(324), height: UIScreen.getHeight(20))
        },
        thumb: {
          Circle()
            .foregroundColor(.white)
            .shadow(radius: 20 / 1)
        },
        thumbSize: CGSize(width: 20, height: 20))
    }
    .onChange(of: isChangeState) { isChange in

      if !(isChange ?? true) {
        value = 1
      }
    }
  }
}

// MARK: - VideoSpeedSlider_Previews

struct VideoSpeedSlider_Previews: PreviewProvider {
  static var previews: some View {
    VideoSpeedSlider(isChangeState: false) { _ in }
  }
}
