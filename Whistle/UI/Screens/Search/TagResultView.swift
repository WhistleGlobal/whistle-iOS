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

  var body: some View {
    VStack(spacing: 0) {
      Text("게시물 \(apiViewModel.tagSearchedRecentContent.count.roundedWithAbbreviations)개")
        .fontSystem(fontDesignSystem: .subtitle3)
        .foregroundColor(.LabelColor_Secondary)
        .frame(height: 30, alignment: .top)
        .padding(.bottom, 5)
      HStack(spacing: 0) {
        SearchTabItem(tabSelected: $tagTabSelection, tabType: .popular)
        SearchTabItem(tabSelected: $tagTabSelection, tabType: .recent)
      }
      .frame(height: 23)
      .padding(.top)
      .padding(.horizontal, 16)
      switch tagTabSelection {
      case .popular:
        taggedVideoList()
      case .recent:
        taggedVideoList()
      }
      Spacer()
    }
    .onAppear {
      UIApplication.shared.endEditing()
    }
    .task {
      apiViewModel.requestTagSearchedRecentContent(queryString: tagText)
    }
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("#\(tagText)")
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(.LabelColor_Primary)
      }
    }
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
        // FIXME: - 태그 검색 결과로 고쳐야함
        ForEach(Array(apiViewModel.tagSearchedRecentContent.enumerated()), id: \.element) { index, content in
          NavigationLink {
            TagSearchFeedView(index: index, userId: content.userId ?? 0)
          } label: {
            videoThumbnailView(
              thumbnailUrl: content.thumbnailUrl ?? "",
              whistleCount: content.whistleCount)
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
}
