//
//  Extension+UINavigationController.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import Foundation
import UIKit

// MARK: - UINavigationController + ObservableObject, UIGestureRecognizerDelegate

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {

  // MARK: Open

  override open func viewDidLoad() {
    super.viewDidLoad()
//    navigationBar.isHidden = true
    interactivePopGestureRecognizer?.delegate = self
  }

  // MARK: Public

  public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }
}
