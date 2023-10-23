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
    Notion(urlToLoad: "https://collabint.notion.site/05eda14c7579447094f88e2eb94a618f?pvs=4")
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
