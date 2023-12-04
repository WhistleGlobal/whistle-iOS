//
//  MainSearchView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import Mixpanel
import SwiftUI
import SwiftyJSON
import UIKit

// MARK: - MainSearchView

struct MainSearchView: View {
  @AppStorage("searchHistory") var searchHistory =
    """
    []
    """
  @Environment(\.dismiss) var dismiss
  @State var searchText = ""
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false
  @State var goSearchResult = false
  @State var searchHistoryArray: [String] = []

  @StateObject var apiViewModel = APIViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 14)
      Divider()

      HStack {
        if searchHistory.contains("[]") {
          Text("최근 검색 결과 없음")
            .foregroundColor(.labelColorSecondary)
            .fontSystem(fontDesignSystem: .body2)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          Text(SearchWords().recentSearces)
            .fontSystem(fontDesignSystem: .subtitle1)
            .foregroundColor(.labelColorPrimary)
          Spacer()
          Button {
            searchHistoryArray.removeAll()
            let jsonArray = searchHistoryArray.map { JSON($0) }
            if let jsonData = try? JSON(jsonArray).rawData() {
              searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
            }
          } label: {
            Text(SearchWords().clearAll)
              .fontSystem(fontDesignSystem: .subtitle3)
              .foregroundColor(.info)
          }
        }
      }
      .padding(.top, 12)
      .padding(.horizontal, 16)

      ScrollView {
        VStack(spacing: 0) {
          ForEach(Array(searchHistoryArray.reversed().enumerated()), id: \.element) { index, item in
            Button {
              searchQueryString = item
              search(query: item)
              goSearchResult = true
            } label: {
              HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                  .font(.system(size: 24))
                  .padding(.trailing, 10)
                  .padding(.vertical, 12)
                HStack(spacing: 0) {
                  Text(item)
                    .fontSystem(fontDesignSystem: .body2)
                    .foregroundColor(.labelColorPrimary)
                  Spacer()
                  Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .frame(width: 16, height: 16)
                    .foregroundColor(.labelColorPrimary)
                    .onTapGesture {
                      searchHistoryArray.remove(at: index)
                      let jsonArray = searchHistoryArray.map { JSON($0) }
                      if let jsonData = try? JSON(jsonArray).rawData() {
                        searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
                      }
                    }
                }
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 16)
            }
            .id(UUID())
            Divider().overlay { Color.Border_Default_Dark }.padding(.leading, 52)
          }
          Spacer().frame(height: 70)
        }
      }
      .ignoresSafeArea()
      Spacer()
    }
    .background(.backgroundDefault)
    .navigationBarBackButtonHidden()
    .overlay {
      NavigationLink(
        destination: SearchResultView(
          searchQueryString: $searchQueryString),
        isActive: $goSearchResult)
      {
        EmptyView()
      }
      .id(UUID())
    }
    .onTapGesture {
      searchQueryString = ""
      UIApplication.shared.endEditing()
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          searchText: $searchQueryString,
          isSearching: $isSearching,
          submitAction: {
            if searchQueryString.isEmpty {
              return
            }
            if !searchHistoryArray.contains(searchQueryString) {
              searchHistoryArray.append(searchQueryString)
              let jsonArray = searchHistoryArray.map { JSON($0) }
              if let jsonData = try? JSON(jsonArray).rawData() {
                searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
              }
            }
            search(query: searchQueryString)
            goSearchResult = true
          },
          cancelTapAction: dismiss)
          .simultaneousGesture(TapGesture().onEnded { })
          .frame(width: UIScreen.width - 32)
      }
    }
    .onAppear {
      searchQueryString = ""
      if let jsonData = searchHistory.data(using: .utf8) {
        let json = try? JSON(data: jsonData)
        searchHistoryArray = json?.arrayValue.map { $0.stringValue } ?? []
      }
    }
  }
}

extension MainSearchView {
  func search(query: String) {
    SearchProgress.shared.reset()
    apiViewModel.searchedTag = []
    apiViewModel.searchedUser = []
    apiViewModel.searchedContent = []
    apiViewModel.requestSearchedContent(queryString: query)

    Mixpanel.mainInstance().people.increment(property: "search_count", by: 1)
    Mixpanel.mainInstance().track(event: "search", properties: [
      "search_term": query,
    ])
  }
}
