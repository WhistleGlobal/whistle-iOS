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
  @StateObject var apiViewModel = APIViewModel.shared

  // test
  @State private var videoCount = 21 // Initial video count

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

enum SearchTabSelection: LocalizedStringKey {
  case content = "콘텐츠"
  case account = "계정"
  case hashtag = "해시태그"
}

// MARK: - ViewBuilders

extension SearchResultView {

  @ViewBuilder
  func searchVideoList() -> some View {
    ScrollView {
      ScrollViewReader { _ in
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
          }
          Color.clear
            .frame(height: 150)
          Color.clear
            .frame(height: 150)
            .overlay {
              ProgressView()
            }
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                videoCount += 21
              }
            }
          Color.clear
            .frame(height: 150)
        }
      }
      .padding(.top, 15)
      .padding(.horizontal, 16)
      .scrollIndicators(.hidden)
    }
  }

  @ViewBuilder
  func searchAccountList() -> some View {
    ScrollView {
      ForEach(apiViewModel.searchedUser, id: \.uuid) { user in
        NavigationLink {
          EmptyView()
        } label: {
          searchAccountRow(user: user)
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
      ForEach(apiViewModel.searchedTag, id: \.uuid) { tag in
        NavigationLink {
          TagResultView(tagText: "#\(tag.contentHashtag)")
        } label: {
          searchTagRow(tag: tag)
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
  func searchAccountRow(user: SearchedUser) -> some View {
    HStack(spacing: 0) {
      profileImageView(url: user.profileImage, size: 48)
        .padding(.trailing, 10)
      VStack(alignment: .leading, spacing: 0) {
        Text(user.userName)
          .fontSystem(fontDesignSystem: .subtitle2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Primary)
        Text(user.introduce ?? "")
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
  func searchTagRow(tag: SearchedTag) -> some View {
    HStack(spacing: 0) {
      Text("#")
        .font(.system(size: 28))
        .lineSpacing(20)
        .foregroundColor(.LabelColor_Primary)
        .frame(width: 48, height: 48)
        .padding(.trailing, 10)
      VStack(alignment: .leading, spacing: 0) {
        Text(tag.contentHashtag)
          .fontSystem(fontDesignSystem: .subtitle2)
          .frame(width: .infinity,alignment: .leading)
          .foregroundColor(.LabelColor_Primary)
        Text("게시물 \(tag.contentHashtagCount.roundedWithAbbreviations)개")
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
