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
  @Published var title: LocalizedStringKey? = nil
  @Published var content: LocalizedStringKey? = nil
  @Published var cancelText: LocalizedStringKey? = nil
  @Published var destructiveText: LocalizedStringKey? = nil
  @Published var submitText: LocalizedStringKey? = nil
  @Published var onFullScreenCover = false
  @Published var isRed = false
  var isImmediateDismiss = false

  var cancelAction: (() -> Void)? = nil
  var destructiveAction: (() -> Void)? = nil
  var submitAction: (() -> Void)? = nil

  func linearAlert(
    showAlert: Bool = true,
    alertStyle: AlertStyle = .linear,
    isRed: Bool = false,
    title: LocalizedStringKey? = nil,
    content: LocalizedStringKey? = nil,
    cancelText: LocalizedStringKey? = CommonWords().cancel,
    destructiveText: LocalizedStringKey? = nil,
    cancelAction: (() -> Void)? = nil,
    destructiveAction: @escaping () -> Void)
  {
//    withAnimation {
    self.showAlert = showAlert
//    }
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
    title: LocalizedStringKey? = nil,
    content: LocalizedStringKey? = nil,
    submitText: LocalizedStringKey? = CommonWords().done,
    submitAction: (() -> Void)? = nil)
  {
//    withAnimation {
    self.showAlert = showAlert
//    }
    self.alertStyle = alertStyle
    self.title = title
    self.content = content
    self.submitText = submitText
    self.submitAction = submitAction
  }

  func stackAlert(
    showAlert: Bool = true,
    alertStyle: AlertStyle = .stack,
    isImmediateDismiss: Bool = false,
    title: LocalizedStringKey? = nil,
    content: LocalizedStringKey? = nil,
    cancelText: LocalizedStringKey? = CommonWords().cancel,
    destructiveText: LocalizedStringKey? = nil,
    cancelAction: (() -> Void)? = nil,
    destructiveAction: @escaping () -> Void)
  {
//    withAnimation {
    self.showAlert = showAlert
//    }
    self.alertStyle = alertStyle
    self.isImmediateDismiss = isImmediateDismiss
    self.title = title
    self.content = content
    self.cancelText = cancelText
    self.destructiveText = destructiveText
    self.cancelAction = cancelAction
    self.destructiveAction = destructiveAction
  }

  func dismissAlert() {
//    withAnimation {
    showAlert = false
//    }
  }

  func immediateDismissAlert() {
    showAlert = false
  }
}
