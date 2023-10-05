//
//  VideoPickerTestView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import SwiftUI
import VideoPicker

// MARK: - PickerConfigViewControllerWrapper

struct PickerConfigViewControllerWrapper: UIViewControllerRepresentable {
  func makeUIViewController(context _: Context) -> PickerConfigViewController {
    let viewController = PickerConfigViewController()
    viewController.modalPresentationStyle = .automatic
    return viewController
  }

  func updateUIViewController(_: PickerConfigViewController, context _: Context) {
    // Update the view controller if needed
  }

  typealias UIViewControllerType = PickerConfigViewController
}
