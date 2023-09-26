//
//  VideoPickerTestView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import SwiftUI
import VideoPicker

// MARK: - VideoPickerTestView

struct VideoPickerTestView: View {
  @State private var isPickerConfigViewPresented = false
  @State private var pickerOptions = PickerOptionsInfo()
  @State private var isFullScreen = true
  var body: some View {
    VStack {
      Button {
        isPickerConfigViewPresented = true
      } label: {
        Text("Show Config View")
      }
    }
    .sheet(isPresented: $isPickerConfigViewPresented) {
      PickerConfigViewControllerWrapper(
        options: $pickerOptions)
    }
  }
}

// MARK: - PickerConfigViewControllerWrapper

struct PickerConfigViewControllerWrapper: UIViewControllerRepresentable {
  @Binding var options: PickerOptionsInfo

  func makeUIViewController(context _: Context) -> PickerConfigViewController {
    let viewController = PickerConfigViewController()
    options.selectLimit = 1
    viewController.options = options
    viewController.modalPresentationStyle = .automatic
    return viewController
  }

  func updateUIViewController(_: PickerConfigViewController, context _: Context) {
    // Update the view controller if needed
  }

  typealias UIViewControllerType = PickerConfigViewController
}

// MARK: - VideoPickerTestView_Previews

struct VideoPickerTestView_Previews: PreviewProvider {
  static var previews: some View {
    VideoPickerTestView()
  }
}
