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
        "history1",
        "history2",
        "history3",
        "history4"
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
      ForEach(Array(searchHistoryArray.enumerated()), id: \.element) { index ,item in
        Button {
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
//        NavigationLink {
//          SearchResultView()
//        } label: {
//          HStack(spacing: 0) {
//            Image(systemName: "magnifyingglass")
//              .font(.system(size: 28))
//              .frame(width: 48, height: 48)
//              .padding(.trailing, 10)
//            Text(item)
//              .fontSystem(fontDesignSystem: .body2)
//              .foregroundColor(.LabelColor_Primary)
//            Spacer()
//            Image(systemName: "xmark")
//              .font(.system(size: 16))
//              .frame(width: 16, height: 16)
//              .foregroundColor(.LabelColor_Primary)
//              .onTapGesture {
//                searchHistoryArray.remove(at: index)
//                let jsonArray = searchHistoryArray.map { JSON($0) }
//                if let jsonData = try? JSON(jsonArray).rawData() {
//                  searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
//                }
//              }
//          }
//          .frame(height: 74)
//        }
//        .padding(.horizontal, 16)
//        .id(UUID())
      }
      Spacer()
    }
    .navigationBarBackButtonHidden()
    .background()
    .overlay {
      NavigationLink(destination: SearchResultView(), isActive: $goSearchResult) {
        EmptyView()
      }
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
            searchQueryString = ""
            goSearchResult = true
          },
          cancelTapAction: dismiss)
          .simultaneousGesture(TapGesture().onEnded {
//                                  tapSearchBar?()
          })
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
