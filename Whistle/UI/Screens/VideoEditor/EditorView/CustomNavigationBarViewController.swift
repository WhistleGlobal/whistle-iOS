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
  var backButtonAction: () -> Void

  func makeUIViewController(context: Context) -> UINavigationController {
    let navigationController = UINavigationController()
    let appearance = UINavigationBarAppearance()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.backgroundColor = UIColor(Color.Background_Default_Dark)

    navigationController.navigationBar.standardAppearance = appearance
    navigationController.navigationBar.scrollEdgeAppearance = appearance

    let viewController = UIViewController()
    viewController.navigationItem.title = title
    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: context.coordinator,
      action: #selector(Coordinator.backButtonTapped))
    viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor(Color.white)
    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "다음",
      style: .plain,
      target: nil,
      action: nil)
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

    init(_ parent: CustomNavigationBarViewController) {
      self.parent = parent
    }

    @objc
    func backButtonTapped() {
      parent.backButtonAction()
    }
  }
}
