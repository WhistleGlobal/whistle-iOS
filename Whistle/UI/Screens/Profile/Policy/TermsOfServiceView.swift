//
//  TermsOfServiceView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/20/23.
//

import SwiftUI

struct TermsOfServiceView: View {
  @Environment(\.dismiss) var dismiss

  var body: some View {
    Notion(urlToLoad: "https://collabint.notion.site/eff44991b3b445f7944f2f24c9bdfeb6?pvs=4")
      .toolbarRole(.editor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("커뮤니티 가이드라인")
            .foregroundStyle(Color.labelColorPrimary)
            .font(.headline)
        }
      }
  }
}

#Preview {
  TermsOfServiceView()
}
