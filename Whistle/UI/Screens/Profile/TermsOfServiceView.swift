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
    NotionWebView(urlToLoad: "https://collabint.notion.site/69b5b5ac5d26435cb39ffcaf14ba837d")
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
