//
//  SearchResultView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI

struct SearchResultView: View {
  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false

  var body: some View {
    VStack(spacing: 0) {
      Text("Hello, World!")
    }
    .navigationBarBackButtonHidden(isSearching)
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          isNeedBackButton: true,
          searchText: $searchQueryString,
          isSearching: $isSearching)
          .simultaneousGesture(TapGesture().onEnded {
            //                      tapSearchBar?()
          })
          .frame(width: UIScreen.width - 32)
      }
    }
  }
}

#Preview {
  SearchResultView()
}
