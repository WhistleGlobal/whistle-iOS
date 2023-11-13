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

  // test
  @State private var videoCount = 10 // Initial video count

  @State private var reachedBottom = false

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        SearchTabItem(tabSelected: $searchTabSelection, tabType: .content)
        SearchTabItem(tabSelected: $searchTabSelection, tabType: .account)
        SearchTabItem(tabSelected: $searchTabSelection, tabType: .hashtag)
      }
      .frame(height: 23)
      .padding(.top)
      .padding(.horizontal, 16)
      switch searchTabSelection {
      case .content:
        searchVideoList()
      case .account:
        searchAccountList()
      case .hashtag:
        searchTagList()
      }
      Spacer()
    }
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          isNeedBackButton: true,
          searchText: $searchQueryString,
          isSearching: $isSearching,
          submitAction: { },
          cancelTapAction: dismiss)
          .simultaneousGesture(TapGesture().onEnded {
            //                      tapSearchBar?()
          })
          .frame(width: UIScreen.width - 63)
      }
    }
    .onDisappear {
      UIApplication.shared.endEditing()
    }
  }
}

#Preview {
  SearchResultView()
}

// MARK: - SearchTabSelection

enum SearchTabSelection: String {
  case content
  case account
  case hashtag
}

// MARK: - ViewBuilders

extension SearchResultView {

  @ViewBuilder
  func searchVideoList() -> some View {
    ScrollView {
      ScrollViewReader { scrollView in
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 8) {
          ForEach(0..<videoCount, id: \.self) { index in
            NavigationLink {
              EmptyView()
            } label: {
              videoThumbnailView(
                thumbnailUrl: "https://picsum.photos/id/\(index)/200/300",
                whistleCount: Int.random(in: 0..<1000000))
            }
            .id(UUID())
            .onAppear {
              if index == videoCount - 1 {
                let scrollPosition = CGFloat(index + 1) *
                  (UIScreen.getHeight(204) + 8)
                scrollView.scrollTo(scrollPosition, anchor: .top)
                videoCount += 10
              }
            }
          }
        }
        Spacer().frame(height: 150)
      }
      .padding(.top, 15)
      .padding(.horizontal, 16)
      .scrollIndicators(.hidden)
    }
  }

  @ViewBuilder
  func searchAccountList() -> some View {
    ScrollView {
      ForEach(0..<10, id: \.self) { _ in
        NavigationLink {
          EmptyView()
        } label: {
          searchAccountRow()
        }
        .padding(.horizontal, 16)
        .id(UUID())
        Divider().frame(height: 0.5).padding(.leading, 74).foregroundColor(.Disable_Placeholder)
      }
      Spacer().frame(height: 150)
    }
    .scrollIndicators(.hidden)
    .padding(.top, 15)
  }

  @ViewBuilder
  func searchTagList() -> some View {
    ScrollView {
      ForEach(0..<10, id: \.self) { _ in
        NavigationLink {
          TagResultView(tagText: "#뽀삐뽀")
        } label: {
          searchTagRow()
        }
        .padding(.horizontal, 16)
        .id(UUID())
        Divider().frame(height: 0.5).padding(.leading, 74).foregroundColor(.Disable_Placeholder)
      }
      Spacer().frame(height: 150)
    }
    .scrollIndicators(.hidden)
    .padding(.top, 15)
  }

  @ViewBuilder
  func searchAccountRow() -> some View {
    HStack(spacing: 0) {
      Image("ProfileDefault")
        .resizable()
        .scaledToFit()
        .frame(width: 48, height: 48)
        .padding(.trailing, 10)
      VStack(alignment: .leading, spacing: 0) {
        Text("Username")
          .fontSystem(fontDesignSystem: .subtitle2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Primary)
        Text("Description")
          .fontSystem(fontDesignSystem: .body2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Secondary)
      }
      Spacer()
      Image(systemName: "chevron.forward")
        .font(.system(size: 16))
        .frame(width: 18, height: 18)
        .foregroundColor(.LabelColor_DisablePlaceholder)
    }
    .frame(height: 74)
  }

  @ViewBuilder
  func searchTagRow() -> some View {
    HStack(spacing: 0) {
      Text("#")
        .font(.system(size: 28))
        .lineSpacing(20)
        .foregroundColor(.LabelColor_Primary)
        .frame(width: 48, height: 48)
        .padding(.trailing, 10)
      VStack(alignment: .leading, spacing: 0) {
        Text("뽀삐뽀")
          .fontSystem(fontDesignSystem: .subtitle2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Primary)
        Text("게시물 \(100000.roundedWithAbbreviations)개")
          .fontSystem(fontDesignSystem: .body2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Secondary)
      }
      Spacer()
      Image(systemName: "chevron.forward")
        .font(.system(size: 16))
        .frame(width: 18, height: 18)
        .foregroundColor(.LabelColor_DisablePlaceholder)
    }
    .frame(height: 74)
  }
}
