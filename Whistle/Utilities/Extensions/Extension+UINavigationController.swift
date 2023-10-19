//
//  Extension+UINavigationController.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - UINavigationController + ObservableObject, UIGestureRecognizerDelegate

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
  // MARK: Open

  override open func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 17.0, *) {
      // iOS 17 이상에서는 아무 동작하지 않음
    } else {
      navigationBar.isHidden = false
      interactivePopGestureRecognizer?.delegate = self
    }
  }

  // MARK: Public

  public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }
}
