//
//  Picker+UIVisualEffectView.swift
//  VideoPicker
//
//  Created by 박상원 on 2023/09/21.
//

import Foundation
import UIKit

extension UIVisualEffectView {
  var backDrop: UIView? {
    subView(forClass: NSClassFromString("_UIVisualEffectBackdropView"))
  }

  var gaussianBlur: NSObject? {
    backDrop?.value(key: "filters", filter: "gaussianBlur")
  }

  var saturation: NSObject? {
    backDrop?.value(key: "filters", filter: "colorSaturate")
  }

  var gaussianBlurRadius: CGFloat {
    get {
      gaussianBlur?.values?["inputRadius"] as? CGFloat ?? 0
    }
    set {
      gaussianBlur?.values?["inputRadius"] = newValue
      backDrop?.perform(Selector(("applyRequestedFilterEffects")))
    }
  }

  var saturationAmount: CGFloat {
    get {
      saturation?.values?["inputAmount"] as? CGFloat ?? 0
    }
    set {
      saturation?.values?["inputAmount"] = newValue
    }
  }
}
