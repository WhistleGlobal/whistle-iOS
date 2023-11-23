//
//  TagResultView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/13/23.
//

import SwiftUI

// MARK: - TagResultView

struct TagResultView: View {

  let tagText: String
  @State var tagTabSelection: TagTabSelection = .popular
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var feedPlayersViewModel = TagSearchPlayersViewModel()

  var body: some View {
    VStack(spacing: 0) {
      Text("게시물 \(apiViewModel.tagSearchedRecentContent.count.roundedWithAbbreviations)개")
        .fontSystem(fontDesignSystem: .subtitle3)
        .foregroundColor(.LabelColor_DisablePlaceholder_Dark)
      HStack(spacing: 0) {
        SearchTabItem(tabSelected: $tagTabSelection, tabType: .popular)
        SearchTabItem(tabSelected: $tagTabSelection, tabType: .recent)
      }
      .padding(.horizontal, 16)
      switch tagTabSelection {
      case .popular:
        taggedVideoList()
          .padding(.top, 16)
      case .recent:
        taggedVideoList()
          .padding(.top, 16)
      }
      Spacer()
    }
    .background(.backgroundDefault)
    .onAppear {
      UIApplication.shared.endEditing()
    }
    .task {
      apiViewModel.requestTagSearchedRecentContent(queryString: tagText) { contents in
        feedPlayersViewModel.searchedContents = contents
      }
    }
    .toolbarRole(.editor)
    .navigationTitle("#\(tagText)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - TagTabSelection

enum TagTabSelection: LocalizedStringKey {
  case popular = "인기순"
  case recent = "최신순"
}

extension TagResultView {
  @ViewBuilder
  func taggedVideoList() -> some View {
    ScrollView {
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
      ], spacing: 8) {
        ForEach(Array(feedPlayersViewModel.searchedContents.enumerated()), id: \.element) { index, content in
          NavigationLink {
            TagSearchFeedView(
              index: index,
              userId: content.userId ?? 0)
              .environmentObject(feedPlayersViewModel)
          } label: {
            videoThumbnailView(
              thumbnailUrl: content.thumbnailUrl ?? "",
              whistleCount: content.whistleCount)
          }
          .id(UUID())
        }
      }
      Spacer().frame(height: 70)
    }
    .padding(.horizontal, 16)
    .scrollIndicators(.hidden)
    .refreshable {
      apiViewModel.requestTagSearchedRecentContent(queryString: tagText) { contents in
        feedPlayersViewModel.searchedContents = contents
      }
    }
  }
}
