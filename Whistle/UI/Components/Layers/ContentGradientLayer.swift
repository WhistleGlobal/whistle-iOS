//
//  ContentGradientLayer.swift
//  Whistle
//
//  Created by 박상원 on 11/3/23.
//

import SwiftUI

struct ContentGradientLayer: View {
  var body: some View {
    LinearGradient(
      colors: [.clear, .black.opacity(0.24)],
      startPoint: .center,
      endPoint: .bottom)
  }
}

#Preview {
  ContentGradientLayer()
}
