//
//  BottomSheetView+KeyboardHeight.swift
//
//
//  Created by Robin Pel on 06/09/2022.
//

#if !os(macOS)
import SwiftUI
import UIKit

class KeyboardHeight: ObservableObject {

  @Published private(set) var value: CGFloat = 0

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc
  private func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      DispatchQueue.main.async {
        self.value = keyboardFrame.cgRectValue.height
      }
    }
  }

  @objc
  private func keyboardWillHide(_: Notification) {
    DispatchQueue.main.async {
      self.value = 0
    }
  }
}
#endif
