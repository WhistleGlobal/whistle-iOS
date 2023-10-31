//
//  AlertViewModel.swift
//  Whistle
//
//  Created by 박상원 on 10/26/23.
//

import Foundation
import SwiftUI

class AlertViewModel: ObservableObject {
  static let shared = AlertViewModel()

  private init() { }

  @Published var showAlert = false
  @Published var alertStyle: AlertStyle = .linear
  @Published var title: String? = nil
  @Published var content: String? = nil
  @Published var cancelText: String? = nil
  @Published var destructiveText: String? = nil
  @Published var submitText: String? = nil
  @Published var onFullScreenCover = false
  @Published var isRed = false

  var cancelAction: (() -> Void)? = nil
  var destructiveAction: (() -> Void)? = nil
  var submitAction: (() -> Void)? = nil

  func linearAlert(
    showAlert: Bool = true,
    alertStyle: AlertStyle = .linear,
    isRed: Bool = false,
    title: String? = nil,
    content: String? = nil,
    cancelText: String? = "취소",
    destructiveText: String? = nil,
    cancelAction: (() -> Void)? = nil,
    destructiveAction: @escaping () -> Void)
  {
    withAnimation {
      self.showAlert = showAlert
    }
    self.alertStyle = alertStyle
    self.title = title
    self.isRed = isRed
    self.content = content
    self.cancelText = cancelText
    self.destructiveText = destructiveText
    self.cancelAction = cancelAction
    self.destructiveAction = destructiveAction
  }

  func submitAlert(
    showAlert: Bool = true,
    alertStyle: AlertStyle = .submit,
    title: String? = nil,
    content: String? = nil,
    submitText: String? = "완료",
    submitAction: (() -> Void)? = nil)
  {
    withAnimation {
      self.showAlert = showAlert
    }
    self.alertStyle = alertStyle
    self.title = title
    self.content = content
    self.submitText = submitText
    self.submitAction = submitAction
  }

  func stackAlert(
    showAlert: Bool = true,
    alertStyle: AlertStyle = .stack,
    title: String? = nil,
    content: String? = nil,
    cancelText: String? = "취소",
    destructiveText: String? = nil,
    cancelAction: (() -> Void)? = nil,
    destructiveAction: @escaping () -> Void)
  {
    withAnimation {
      self.showAlert = showAlert
    }
    self.alertStyle = alertStyle
    self.title = title
    self.content = content
    self.cancelText = cancelText
    self.destructiveText = destructiveText
    self.cancelAction = cancelAction
    self.destructiveAction = destructiveAction
  }

  func dismissAlert() {
    withAnimation {
      self.showAlert = false
    }
  }
}
