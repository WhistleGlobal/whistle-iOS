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

  var body: some View {
    VStack(spacing: 0) {
      Text("게시물 100개")
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
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(tagText)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(.LabelColor_Primary)
      }
    }
  }
}

// MARK: - TagTabSelection

enum TagTabSelection: String {
  case popular
  case recent
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
        ForEach(0..<10, id: \.self) { _ in
          NavigationLink {
            EmptyView()
          } label: {
            videoThumbnailView(
              thumbnailUrl: "https://picsum.photos/id/\(Int.random(in: 0..<200))/200/300",
              whistleCount: Int.random(in: 0..<1000000))
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
