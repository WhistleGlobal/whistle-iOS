//
//  SubmitButton.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import SwiftUI

// MARK: - SubmitButton

struct SubmitButton: View {
  var body: some View {
    Button {
      print("Button Clicked")
    } label: {
      Text("Click me")
    }
  }
}

// MARK: - SubmitButton_Previews

struct SubmitButton_Previews: PreviewProvider {
  static var previews: some View {
    SubmitButton()
  }
}
