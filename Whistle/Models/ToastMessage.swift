////
////  ToastViewModel.swift
////  Whistle
////
////  Created by 박상원 on 10/25/23.
////

import Foundation
import SwiftUI

class ToastViewModel: ObservableObject {
  static let shared = ToastViewModel()

  private init() { }

  @Published var showToast = false
  @Published var message: LocalizedStringKey = ""
  @Published var padding: CGFloat = 58
  @Published var isCancelled = false

  @Published var isCancellable = false
  var cancellableAction: (() -> Void)? = { }

  func toastInit(
    showToast: Bool = true,
    message: LocalizedStringKey,
    padding: CGFloat = 58)
  {
    withAnimation {
      self.showToast = showToast
    }
    self.message = message
    self.padding = padding
    isCancellable = false
    cancellableAction = nil
  }

  func cancelToastInit(
    showToast: Bool = true,
    message: LocalizedStringKey,
    isCancelled _: Bool = false,
    padding: CGFloat = 58,
    cancelAction: @escaping () -> Void)
  {
    withAnimation {
      self.showToast = showToast
    }
    isCancellable = true
    isCancelled = false
    self.message = message
    self.padding = padding
    cancellableAction = cancelAction
  }

  func cancelCancellableAction() {
    isCancelled = true
  }
}
