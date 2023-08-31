//
//  Extension+UIVisualEffectView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

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
      backDrop?.perform(Selector("applyRequestedFilterEffects"))
    }
  }

  var saturationAmout: CGFloat {
    get {
      saturation?.values?["inputAmount"] as? CGFloat ?? 0
    }
    set {
      saturation?.values?["inputAmount"] = newValue
    }
  }
}
