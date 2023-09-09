//
//  HapticsManager.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//

import SwiftUI

class HapticManager {
  static let instance = HapticManager()

  func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }

  func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
  }
}
