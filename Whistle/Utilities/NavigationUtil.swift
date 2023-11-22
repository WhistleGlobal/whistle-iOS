//
//  NavigationUtil.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import Foundation
import UIKit

extension UIApplication {
  class func topNavigationController(
    viewController: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)
    -> UINavigationController?
  {
    if let nav = viewController as? UINavigationController {
      return nav
    }
    if let tab = viewController as? UITabBarController {
      if let selected = tab.selectedViewController {
        if !selected.children.isEmpty {
          return selected.children.first as? UINavigationController
        }
      }
    }
    guard let viewController else {
      return nil
    }
    for childViewController in viewController.children {
      return topNavigationController(
        viewController:
        childViewController)
    }
    return nil
  }
}

// MARK: - NavigationUtil

enum NavigationUtil {
  static func popToRootView() {
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      findNavigationController(
        viewController:
        UIApplication.topNavigationController())?
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
