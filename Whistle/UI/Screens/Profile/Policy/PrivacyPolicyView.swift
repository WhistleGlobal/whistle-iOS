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
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("개인정보 처리 방침")
            .foregroundStyle(Color.labelColorPrimary)
            .font(.headline)
        }
      }
      .toolbarRole(.editor)
  }
}

#Preview {
  NavigationStack {
    PrivacyPolicyView()
  }
}
