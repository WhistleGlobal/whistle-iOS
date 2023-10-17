//
//  PickerConfigViewControllerWrapper.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import Combine
import SwiftUI
import VideoPicker

// MARK: - PickerConfigViewControllerWrapper

struct PickerConfigViewControllerWrapper: UIViewControllerRepresentable {
  @Binding var isImagePickerClosed: PassthroughSubject<Bool, Never>

  func makeUIViewController(context _: Context) -> PickerConfigViewController {
    let viewController = PickerConfigViewController()
    viewController.modalPresentationStyle = .automatic

    viewController.isImagePickerClosed = isImagePickerClosed
    viewController.isImagePickerClosed?
      .sink { isClosed in
        print("combine", isClosed)
      }
      .store(in: &viewController.cancellables)

    return viewController
  }

  func updateUIViewController(_: PickerConfigViewController, context _: Context) {
    // Update the view controller if needed
  }

  typealias UIViewControllerType = PickerConfigViewController
}
