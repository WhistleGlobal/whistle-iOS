//
//  SearchResultView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import Mixpanel
import SwiftUI
import SwiftyJSON

// MARK: - SearchResultView

struct SearchResultView: View {
  @AppStorage("searchHistory") var searchHistory =
    """
    []
    """
  @Environment(\.dismiss) var dismiss
  @State var scopeSelection = 0
  @State var isSearching = false
  @State var searchTabSelection: SearchTabSelection = .content
  @StateObject var apiViewModel = APIViewModel.shared
  @State var contentSearchState: SearchState = .notStarted
  @State var userSearchState: SearchState = .notStarted
  @State var tagSearchState: SearchState = .notStarted
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
    .background(.backgroundDefault)
    .id(UUID())
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        FeedSearchBar(
          isNeedBackButton: true,
          searchText: $inputText,
          isSearching: $isSearching,
          submitAction: {
            WhistleLogger.logger.debug("submit inputText: \(inputText)")
            if inputText.isEmpty {
              return
            }
            if let jsonData = searchHistory.data(using: .utf8) {
              do {
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String] {
                  print(jsonArray)
                  var searchArray = jsonArray
                  if !searchArray.contains(inputText) {
                    searchArray.append(inputText)
                  }
                  if let jsonData = try? JSON(searchArray).rawData() {
                    searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
                  }
                  SearchProgress.shared.reset()
                  searchQueryString = inputText
                  search(query: inputText)
                }

              } catch {
                print("JSON 파싱 에러: \(error.localizedDescription)")
              }
            } else {
              print("JSON 문자열을 Data로 변환하는 데 문제가 발생했습니다.")
            }
            let jsonArray = JSON(searchHistory)
            if !searchHistory.contains(inputText) {
              searchHistory.append(inputText)
            }
            WhistleLogger.logger.debug("submit searchHistory: \(searchHistory)")
//            let jsonArray = JSON(searchHistory)
            WhistleLogger.logger.debug("submit jsonArray: \(jsonArray)")
            if let jsonData = try? JSON(jsonArray).rawData() {
              WhistleLogger.logger.debug("submit jsonData: \(jsonData)")
              searchHistory = String(data: jsonData, encoding: .utf8) ?? ""
              WhistleLogger.logger.debug("submit searchHistory: \(searchHistory)")
            }
            SearchProgress.shared.reset()
            searchQueryString = inputText
            WhistleLogger.logger.debug("submit searchQueryString: \(searchQueryString)")
            search(query: inputText)
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
    .onReceive(SearchProgress.shared.searchContentSubject) { newValue in
      contentSearchState = newValue
      if newValue == .searching {
        apiViewModel.searchedContent = []
        apiViewModel.requestSearchedContent(queryString: inputText)
      }
    }
    .onReceive(SearchProgress.shared.searchUserSubject) { newValue in
      userSearchState = newValue
      if newValue == .searching {
        apiViewModel.searchedUser = []
        apiViewModel.requestSearchedUser(queryString: inputText)
      }
    }
    .onReceive(SearchProgress.shared.searchTagSubject) { newValue in
      tagSearchState = newValue
      if newValue == .searching {
        apiViewModel.searchedTag = []
        apiViewModel.requestSearchedTag(queryString: inputText)
      }
    }
    .onChange(of: searchTabSelection) { value in
      switch value {
      case .content:
        if SearchProgress.shared.searchingContent == .notStarted {
          SearchProgress.shared.changeSearchContentState(to: .searching)
        }
      case .account:
        if SearchProgress.shared.searchingUser == .notStarted {
          SearchProgress.shared.changeSearchUserState(to: .searching)
        }
      case .hashtag:
        if SearchProgress.shared.searchingTag == .notStarted {
          SearchProgress.shared.changeSearchTagState(to: .searching)
        }
      }
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
    switch contentSearchState {
    case .notStarted, .searching:
      ProgressView()
        .padding()
    case .found:
      ScrollView {
        VStack {
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
          .padding(.horizontal, 16)
          Spacer().frame(height: 70)
        }
      }
      .padding(.top, 16)
      .scrollIndicators(.hidden)
      .refreshable {
        apiViewModel.requestSearchedContent(queryString: searchQueryString)
      }
    case .notFound:
      searchEmptyView()
    }
  }

  @ViewBuilder
  func searchAccountList() -> some View {
    switch userSearchState {
    case .notStarted, .searching:
      ProgressView()
        .padding()
    case .found:
      ScrollView {
        VStack(spacing: 0) {
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
            Divider().overlay { Color.Border_Default_Dark }.padding(.leading, 74)
          }
          Spacer().frame(height: 70)
        }
      }
      .scrollIndicators(.hidden)
      .refreshable {
        apiViewModel.requestSearchedUser(queryString: searchQueryString)
      }
    case .notFound:
      searchEmptyView()
    }
  }

  @ViewBuilder
  func searchTagList() -> some View {
    switch tagSearchState {
    case .notStarted, .searching:
      ProgressView()
        .padding()
    case .found:
      ScrollView {
        VStack(spacing: 0) {
          ForEach(apiViewModel.searchedTag, id: \.uuid) { tag in
            NavigationLink {
              TagResultView(tagText: "\(tag.contentHashtag)")
            } label: {
              searchTagRow(tag: tag)
            }
            .padding(.horizontal, 16)
            .id(UUID())
            Divider().overlay { Color.Border_Default_Dark }.padding(.leading, 74)
          }
          Spacer().frame(height: 70)
        }
      }
      .scrollIndicators(.hidden)
      .refreshable {
        apiViewModel.requestSearchedTag(queryString: searchQueryString)
      }
    case .notFound:
      searchEmptyView()
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
          .foregroundColor(.labelColorPrimary)
        if !(user.introduce?.replacingOccurrences(of: " ", with: "") ?? "").isEmpty {
          Text(user.introduce?.trimmingCharacters(in: .whitespaces) ?? "")
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.labelColorSecondary)
            .lineLimit(1)
        }
      }
      Spacer()
      Image(systemName: "chevron.forward")
        .font(.system(size: 16))
        .frame(width: 18, height: 18)
        .foregroundColor(.labelColorDisablePlaceholder)
    }
    .frame(height: 74)
  }

  @ViewBuilder
  func searchTagRow(tag: SearchedTag) -> some View {
    HStack(spacing: 0) {
      Text("#")
        .font(.system(size: 28, design: .rounded))
        .foregroundColor(.labelColorPrimary)
        .frame(width: 48, height: 48)
        .padding(.trailing, 10)
      VStack(alignment: .leading, spacing: 0) {
        Text(tag.contentHashtag)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(.labelColorPrimary)
        Text("게시물 \(tag.contentHashtagCount.roundedWithAbbreviations)개")
          .fontSystem(fontDesignSystem: .body2)
          .foregroundColor(.labelColorSecondary)
      }
      Spacer()
      Image(systemName: "chevron.forward")
        .font(.system(size: 16))
        .frame(width: 18, height: 18)
        .foregroundColor(.labelColorDisablePlaceholder)
    }
    .frame(height: 74)
  }

  @ViewBuilder
  func searchEmptyView() -> some View {
    HStack {
      Text("\"\(searchQueryString)\" 검색결과 없음")
        .fontSystem(fontDesignSystem: .body2)
        .foregroundColor(.labelColorSecondary)
        .padding(.vertical, 14)
      Spacer()
    }
    .padding(.horizontal, 16)
  }
}

extension SearchResultView {
  func search(query: String) {
    searchQueryString = inputText
    switch searchTabSelection {
    case .content:
      SearchProgress.shared.changeSearchContentState(to: .searching)
    case .account:
      SearchProgress.shared.changeSearchUserState(to: .searching)
    case .hashtag:
      SearchProgress.shared.changeSearchTagState(to: .searching)
    }
    Mixpanel.mainInstance().people.increment(property: "search_count", by: 1)
    Mixpanel.mainInstance().track(event: "search", properties: [
      "search_term": query,
    ])
  }
}
