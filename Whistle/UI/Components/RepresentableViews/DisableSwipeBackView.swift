//
//  DisableSwipeBackView.swift
//  Whistle
//
//  Created by 박상원 on 11/9/23.
//

import SwiftUI
import UIKit

// MARK: - DisableSwipeBackView

struct DisableSwipeBackView: UIViewControllerRepresentable {
  typealias UIViewControllerType = DisableSwipeBackViewController

  func makeUIViewController(context _: Context) -> UIViewControllerType {
    UIViewControllerType()
  }

  func updateUIViewController(_: UIViewControllerType, context _: Context) { }
}

// MARK: - DisableSwipeBackViewController

class DisableSwipeBackViewController: UIViewController {
  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    if
      let parent = parent?.parent,
      let navigationController = parent.navigationController,
      let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer
    {
      navigationController.view.removeGestureRecognizer(interactivePopGestureRecognizer)
    }
  }
}
