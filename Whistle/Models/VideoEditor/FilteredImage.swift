//
//  FilteredImage.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreImage
import Foundation
import SwiftUI

// MARK: - FilteredImage

struct FilteredImage: Identifiable {
  var id: UUID = .init()
  var image: UIImage
  var filter: CIFilter
}

// MARK: - CorrectionType

enum CorrectionType: String, CaseIterable {
  case brightness = "Brightness"
  case contrast = "Contrast"
  case saturation = "Saturation"

  var key: String {
    switch self {
    case .brightness: kCIInputBrightnessKey
    case .contrast: kCIInputContrastKey
    case .saturation: kCIInputSaturationKey
    }
  }
}

// MARK: - ColorCorrection

struct ColorCorrection {
  var brightness: Double = 0
  var contrast: Double = 0
  var saturation: Double = 0
}
