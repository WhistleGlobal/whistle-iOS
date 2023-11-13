//
//  SearchResultView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI

// MARK: - SearchResultView

struct SearchResultView: View {
  @Environment(\.dismiss) var dismiss
  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false
  @State var searchTabSelection: SearchTabSelection = .content

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        SearchTabItemView(tabSelected: $searchTabSelection, tabType: .content)
        SearchTabItemView(tabSelected: $searchTabSelection, tabType: .account)
        SearchTabItemView(tabSelected: $searchTabSelection, tabType: .hashtag)
      }
      .padding(.top, 20)
      .padding(.horizontal, 16)
      .frame(height: 23)
      Spacer()
    }
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          isNeedBackButton: true,
          searchText: $searchQueryString,
          isSearching: $isSearching,
          cancelTapAction: dismiss)
          .simultaneousGesture(TapGesture().onEnded {
            //                      tapSearchBar?()
          })
          .frame(width: UIScreen.width - 63)
      }
    }
  }
}

#Preview {
  SearchResultView()
}

// MARK: - SearchTabItemView

struct SearchTabItemView: View {

  @Binding var tabSelected: SearchTabSelection
  let tabType: SearchTabSelection
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        Spacer()
        Rectangle()
          .foregroundColor(Color.Gray30_Dark)
          .frame(height: 1)
          .overlay {
            Capsule()
              .frame(height: 2)
              .foregroundColor(.LabelColor_Primary)
              .opacity(tabType == tabSelected ? 1 : 0)
          }
      }
      Text(tabType.rawValue)
        .fontSystem(fontDesignSystem: .subtitle3)
        .fontWeight(.semibold)
        .foregroundColor(tabType == tabSelected ? Color.LabelColor_Primary : Color.Disable_Placeholder)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onTapGesture {
      tabSelected = tabType
    }
  }
}

// MARK: - SearchTabSelection

enum SearchTabSelection: String {
  case content
  case account
  case hashtag
}
