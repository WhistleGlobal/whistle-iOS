//
//  MainSearchView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI
import UIKit

// MARK: - MainSearchView

struct MainSearchView: View {

  @Environment(\.dismiss) var dismiss
  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false

  var body: some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 14)
      Divider()
      HStack {
        Text("최근 검색")
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.LabelColor_Primary)
        Spacer()
        Button {
          //
        } label: {
          Text("모두 지우기")
            .fontSystem(fontDesignSystem: .subtitle3)
            .foregroundColor(.info)
        }
      }
      .padding(.horizontal, 16)
      .frame(height: 50)
      // 검색 목록 넣을 것
      NavigationLink {
        SearchResultView()
      } label: {
        HStack(spacing: 0) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 28))
            .frame(width: 48, height: 48)
            .padding(.trailing, 10)
          Text("뽀삐뽀삐뽀뽀삐뽀")
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.LabelColor_Primary)
          Spacer()
          Image(systemName: "xmark")
            .font(.system(size: 16))
            .frame(width: 16, height: 16)
            .foregroundColor(.LabelColor_Primary)
            .onTapGesture {
              WhistleLogger.logger.debug("x remove")
            }
        }
        .frame(height: 74)
      }
      .padding(.horizontal, 16)
      Spacer()
    }
    .navigationBarBackButtonHidden()
    .background()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          searchText: $searchQueryString,
          isSearching: $isSearching,
          cancelTapAction: dismiss)
          .simultaneousGesture(TapGesture().onEnded {
            //                      tapSearchBar?()
          })
          .frame(width: UIScreen.width - 32)
      }
    }
  }
}
