//
//  VideoCaptureState.swift
//  Whistle
//
//  Created by 박상원 on 11/10/23.
//

import Foundation
import SwiftUI

enum VideoCaptureState {
  case idle
  case recording
  case completed

  var size: (dimSize: CGFloat, buttonRadius: CGFloat, buttonSize: CGFloat) {
    switch self {
    case .idle, .completed:
      (72, 100, 72)
    case .recording:
      (114, 8, 36)
    }
  }

  var buttonColor: LinearGradient {
    switch self {
    case .idle:
      LinearGradient(
        gradient: Gradient(colors: [Color.Primary_Default, Color.Secondary_Default]),
        startPoint: .trailing,
        endPoint: .leading)
    case .completed, .recording:
      LinearGradient(colors: [Color.white], startPoint: .trailing, endPoint: .leading)
    }
  }

  var bottomPadding: CGFloat {
    switch self {
    case .idle, .recording:
      90
    case .completed:
      46
    }
  }

  var horizontalPadding: CGFloat {
    switch self {
    case .idle, .recording:
      30
    case .completed:
      16
    }
  }
}
