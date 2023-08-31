//
//  Extension+UIView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import UIKit

extension UIView {
  func subView(forClass: AnyClass?) -> UIView? {
    subviews.first { view in
      type(of: view) == forClass
    }
  }
}
