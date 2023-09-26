//
//  Picker+UIView.swift
//  VideoPicker
//
//  Created by 박상원 on 2023/09/21.
//

import Foundation
import UIKit

extension UIView {
  func subView(forClass: AnyClass?) -> UIView? {
    subviews.first { view in
      type(of: view) == forClass
    }
  }
}
