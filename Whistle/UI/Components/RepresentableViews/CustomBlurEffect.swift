//
//  CustomBlurView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import Foundation
import SwiftUI

struct CustomBlurEffect: UIViewRepresentable {
  var effect: UIBlurEffect.Style
  var onChange: (UIVisualEffectView) -> Void

  func makeUIView(context _: Context) -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
    return view
  }

  func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
    DispatchQueue.main.async {
      onChange(uiView)
    }
  }
}
