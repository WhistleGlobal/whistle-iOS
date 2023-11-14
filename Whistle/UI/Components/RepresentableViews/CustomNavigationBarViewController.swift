//
//  CustomNavigationBarViewController.swift
//  Whistle
//
//  Created by 박상원 on 2023/10/01.
//
import Foundation
import SwiftUI
import UIKit

struct CustomNavigationBarViewController: UIViewControllerRepresentable {
  var title: String
  var nextText = "다음"
  var isPostNavBar = false
  var backgroundColor = Color.Background_Default_Dark
  var backButtonAction: () -> Void
  var nextButtonAction: () -> Void

  func makeUIViewController(context: Context) -> UINavigationController {
    let navigationController = UINavigationController()
    let appearance = UINavigationBarAppearance()
    appearance.titleTextAttributes = [
      .foregroundColor: backgroundColor == .Background_Default_Dark
        ? UIColor.white
        : UIColor.black,
    ]
    appearance.backgroundColor = UIColor(backgroundColor)
    navigationController.hidesBarsWhenKeyboardAppears = false
    navigationController.navigationBar.standardAppearance = appearance
    navigationController.navigationBar.scrollEdgeAppearance = appearance

    let viewController = UIViewController()
    viewController.navigationItem.title = NSLocalizedString(title, comment: "")
    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: context.coordinator,
      action: #selector(Coordinator.backButtonTapped))
    viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor(
      backgroundColor == .Background_Default_Dark
        ? Color.white
        : Color.black)
    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: NSLocalizedString(nextText, comment: ""),
      style: .plain,
      target: context.coordinator,
      action: #selector(Coordinator.nextButtonTapped))
    viewController.navigationItem.rightBarButtonItem?.tintColor = UIColor(Color.Info)
    viewController.navigationItem.rightBarButtonItem?.style = .done
    navigationController.pushViewController(viewController, animated: false)
    context.coordinator.parent = self
    return navigationController
  }

  func updateUIViewController(_: UINavigationController, context _: Context) { }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    var parent: CustomNavigationBarViewController
    var isNextButtonEnabled = true

    init(_ parent: CustomNavigationBarViewController) {
      self.parent = parent
    }

    @objc
    func backButtonTapped() {
      parent.backButtonAction()
    }

    @objc
    func nextButtonTapped() {
      if isNextButtonEnabled {
        parent.nextButtonAction()
        if parent.isPostNavBar {
          isNextButtonEnabled = false
        }
      }
    }
  }
}
