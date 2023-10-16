//
//  TermsOfServiceView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/20/23.
//

import MarkdownUI
import SwiftUI

struct TermsOfServiceView: View {

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NotionWebView(urlToLoad: "https://collabint.notion.site/eff44991b3b445f7944f2f24c9bdfeb6?pvs=4")
      .navigationTitle("커뮤니티 가이드라인")
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
  TermsOfServiceView()
}
