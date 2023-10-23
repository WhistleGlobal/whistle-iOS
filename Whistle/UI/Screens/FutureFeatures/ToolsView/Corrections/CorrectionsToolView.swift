//
//  CorrectionsToolView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - CorrectionsToolView

struct CorrectionsToolView: View {
  @State var currentTab: CorrectionType = .brightness
  @Binding var correction: ColorCorrection
  let onChange: (ColorCorrection) -> Void
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        ForEach(CorrectionType.allCases, id: \.self) { type in
          Text(type.rawValue)
            .font(.subheadline)
            .hCenter()
            .foregroundColor(currentTab == type ? .white : .secondary)
            .onTapGesture {
              currentTab = type
            }
        }
      }
      slider
    }
  }
}

// MARK: - CorrectionsToolView_Previews

struct CorrectionsToolView_Previews: PreviewProvider {
  static var previews: some View {
    CorrectionsToolView(correction: .constant(EditableVideo.mock.colorCorrection), onChange: { _ in })
  }
}

extension CorrectionsToolView {
  private var slider: some View {
    let value = getValue(currentTab)

    return VStack {
      Text(String(format: "%.1f", value.wrappedValue))
        .font(.subheadline)
      Slider(value: value, in: -1 ... 1) { change in
        if !change {
          onChange(correction)
        }
      }
      .tint(Color.white)
    }
  }

  func getValue(_ type: CorrectionType) -> Binding<Double> {
    switch type {
    case .brightness:
      return $correction.brightness
    case .contrast:
      return $correction.contrast
    case .saturation:
      return $correction.saturation
    }
  }
}
