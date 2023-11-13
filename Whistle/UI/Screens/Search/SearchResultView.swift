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

// MARK: - ViewBuilders

extension SearchResultView {

  @ViewBuilder
  func searchVideoList() -> some View {
    ScrollView {
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
      ], spacing: 8) {
        ForEach(0..<10, id: \.self) { _ in
          NavigationLink {
            EmptyView()
          } label: {
            videoThumbnailView(
              thumbnailUrl: "https://picsum.photos/id/\(Int.random(in: 0..<200))/200/300",
              whistleCount: Int.random(in: 0..<100))
          }
          .id(UUID())
        }
      }
      Spacer().frame(height: 150)
    }
    .padding(.top, 15)
    .padding(.horizontal, 16)
    .scrollIndicators(.hidden)
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
          EmptyView()
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
        Text("게시물 100개")
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
