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

extension UIVisualEffectView {
  static func glassView(
    cornerRadius: CGFloat = 0,
    masksToBounds: Bool = false,
    boundArray _: [UIView.AutoresizingMask] = [.flexibleWidth, .flexibleHeight])
    -> UIVisualEffectView
  {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    view.saturationAmount = 2.2
    view.gaussianBlurRadius = 36
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = masksToBounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return view
  }
}
