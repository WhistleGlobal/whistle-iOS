//
//  PrivacyPolicyView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/20/23.
//

import Combine
import SwiftUI
import UIKit
import WebKit

// MARK: - PrivacyPolicyView

struct PrivacyPolicyView: View {

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NotionWebView(urlToLoad: "https://collabint.notion.site/b2a8b9c9f94f459497b3ec1de73406f1")
      .navigationTitle("개인정보 처리 방침")
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.backward")
              .font(.system(size: 20))
              .foregroundColor(.LabelColor_Primary)
          }
        }
      }
  }
}

#Preview {
  NavigationStack {
    PrivacyPolicyView()
  }
}
