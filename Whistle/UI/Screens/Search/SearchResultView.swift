//
//  SearchResultView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI
import SwiftyJSON

// MARK: - SearchResultView

struct SearchResultView: View {
  @AppStorage("searchHistory") var searchHistory =
    """
        [
      ]
    """
  @Environment(\.dismiss) var dismiss
  @State var scopeSelection = 0
  @State var isSearching = false
  @State var searchHistoryArray: [String] = []
  @State var searchTabSelection: SearchTabSelection = .content
  @StateObject var apiViewModel = APIViewModel.shared

  // test
  @State private var videoCount = 21 // Initial video count

  @State private var reachedBottom = false
  @State var inputText = ""
  @Binding var searchQueryString: String

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
    .id(UUID())
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          isNeedBackButton: true,
          searchText: $inputText,
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
          },
          cancelTapAction: dismiss)
          .frame(width: UIScreen.width - 63)
      }
    }
    .onAppear {
      inputText = searchQueryString
    }
    .onDisappear {
      UIApplication.shared.endEditing()
    }
  }
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
    if apiViewModel.searchedContent.isEmpty {
      searchEmptyView()
    } else {
      ScrollView {
        ScrollViewReader { _ in
          LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
          ], spacing: 8) {
            ForEach(Array(apiViewModel.searchedContent.enumerated()), id: \.element) { index, content in
              NavigationLink {
                SearchFeedView(index: index, userId: content.userId ?? 0)
              } label: {
                videoThumbnailView(
                  thumbnailUrl: "\(content.thumbnailUrl ?? "")",
                  whistleCount: content.whistleCount)
              }
              .id(UUID())
            }
            // // 페이징 구현시 사용할 것들
            // Color.clear
            //  .frame(height: 150)
            // Color.clear
            //  .frame(height: 150)
            //  .overlay {
            //    ProgressView()
            //  }
            //  .onAppear {
            //    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //      videoCount += 21
            //    }
            //  }
            // Color.clear
            //  .frame(height: 150)
          }
        }
        .padding(.top, 15)
        .padding(.horizontal, 16)
        .scrollIndicators(.hidden)
      }
      .scrollIndicators(.hidden)
      .padding(.top, 15)
    }
  }

  @ViewBuilder
  func searchAccountList() -> some View {
    if apiViewModel.searchedUser.isEmpty {
      searchEmptyView()
    } else {
      ScrollView {
        ForEach(apiViewModel.searchedUser, id: \.uuid) { user in
          NavigationLink {
            ProfileView(
              profileType:
              user.userID == apiViewModel.myProfile.userId
                ? .my
                : .member,
              isFirstProfileLoaded: .constant(true),
              userId: user.userID)
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
  }

  @ViewBuilder
  func searchTagList() -> some View {
    if apiViewModel.searchedTag.isEmpty {
      searchEmptyView()
    } else {
      ScrollView {
        ForEach(apiViewModel.searchedTag, id: \.uuid) { tag in
          NavigationLink {
            TagResultView(tagText: "\(tag.contentHashtag)")
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
        if !(user.introduce ?? "").isEmpty {
          Text(user.introduce ?? "")
            .fontSystem(fontDesignSystem: .body2)
            .frame(width: .infinity,alignment: .leading)
            .foregroundColor(.LabelColor_Secondary)
            .multilineTextAlignment(.leading)
        }
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

  @ViewBuilder
  func searchEmptyView() -> some View {
    HStack {
      Text("\"\(searchQueryString)\" 검색결과 없음")
        .fontSystem(fontDesignSystem: .body2)
        .foregroundColor(.LabelColor_Secondary)
        .frame(width: .infinity, alignment: .leading)
        .padding(.vertical, 14)
      Spacer()
    }
    .padding(.horizontal, 16)
  }
}

extension SearchResultView {
  func search(query: String) {
    searchQueryString = inputText
    apiViewModel.searchedTag = []
    apiViewModel.searchedUser = []
    apiViewModel.searchedContent = []
    apiViewModel.requestSearchedUser(queryString: query)
    apiViewModel.requestSearchedTag(queryString: query)
    apiViewModel.requestSearchedContent(queryString: query)
  }
}
