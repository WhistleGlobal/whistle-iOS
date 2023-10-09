//
//  NavigationUtil.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import Foundation
import UIKit

struct NavigationUtil {
  static func popToRootView() {
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      findNavigationController(
        viewController:
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
        .popToRootViewController(animated: true)
    }
  }

  static func findNavigationController(viewController: UIViewController?)
    -> UINavigationController?
  {
    guard let viewController else {
      return nil
    }
    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }
    for childViewController in viewController.children {
      return findNavigationController(
        viewController:
        childViewController)
    }
    return nil
  }
}
