//
//  MainSearchView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI
import SwiftyJSON
import UIKit


// MARK: - MainSearchView

struct MainSearchView: View {
  @AppStorage("searchHistory") var searchHistory =
    """
        [
      ]
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
        Text(SearchWords().recentSearces)
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.LabelColor_Primary)
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
      .padding(.horizontal, 16)
      .frame(height: 50)
      ForEach(Array(searchHistoryArray.enumerated()), id: \.element) { index ,item in
        Button {
          search(query: item)
          goSearchResult = true
        } label: {
          HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 28))
              .frame(width: 48, height: 48)
              .padding(.trailing, 10)
            Text(item)
              .fontSystem(fontDesignSystem: .body2)
              .foregroundColor(.LabelColor_Primary)
            Spacer()
            Image(systemName: "xmark")
              .font(.system(size: 16))
              .frame(width: 16, height: 16)
              .foregroundColor(.LabelColor_Primary)
              .onTapGesture {
                searchHistoryArray.remove(at: index)
                let jsonArray = searchHistoryArray.map { JSON($0) }
                if let jsonData = try? JSON(jsonArray).rawData() {
                  searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
                }
              }
          }
          .frame(height: 74)
        }
        .padding(.horizontal, 16)
        .id(UUID())
      }
      Spacer()
    }
    .navigationBarBackButtonHidden()
    .background()
    .overlay {
      NavigationLink(destination: SearchResultView(), isActive: $goSearchResult) {
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
            if searchHistoryArray.contains(searchQueryString) || searchQueryString.isEmpty {
              return
            }
            searchHistoryArray.append(searchQueryString)
            let jsonArray = searchHistoryArray.map { JSON($0) }
            if let jsonData = try? JSON(jsonArray).rawData() {
              searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
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
      if let jsonData = searchHistory.data(using: .utf8) {
        let json = try? JSON(data: jsonData)
        searchHistoryArray = json?.arrayValue.map { $0.stringValue } ?? []
      }
    }
  }
}

extension MainSearchView {
  func search(query: String) {
    apiViewModel.searchedTag = []
    apiViewModel.searchedUser = []
    apiViewModel.requestSearchedUser(queryString: query)
    apiViewModel.requestSearchedTag(queryString: query)
    apiViewModel.requestSearchedContent(queryString: query)
    searchQueryString = ""
  }
}
