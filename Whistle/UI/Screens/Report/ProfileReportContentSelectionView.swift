//
//  ProfileReportContentSelectionView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import Kingfisher
import SwiftUI

// MARK: - ProfileReportContentSelectionView

struct ProfileReportContentSelectionView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @ObservedObject var memberContentViewModel: MemberContentViewModel
  @State var isSelected = false
  @State var selectedIndex = 0
  @Binding var selectedContentId: Int
  @Binding var goReport: Bool

  let userId: Int
  let reportCategory: ProfileReportTypeSelectionView.ReportCategory
  let reportReason: Int?

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 8) {
          ForEach(Array(memberContentViewModel.memberFeed.enumerated()), id: \.element) { index, content in
            if let url = content.thumbnailUrl {
              videoThumbnail(url: url, index: index)
                .onTapGesture {
                  if reportCategory == .user {
                    selectedIndex = selectedIndex == index ? -1 : index
                  } else {
                    selectedIndex = index
                  }
                  if selectedIndex < 0 {
                    selectedContentId = -1
                  } else {
                    selectedContentId = memberContentViewModel.memberFeed[index].contentId ?? 0
                  }
                }
            }
          }
        }
      }
      .padding(.top, 12)
    }
    .padding(.horizontal, 16)
    .background(Color.backgroundDefault)
    .toolbarRole(.editor)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        NavigationLink {
          switch reportCategory {
          case .post:
            ProfileReportReasonSelectionView(
              memberContentViewModel: memberContentViewModel,
              goReport: $goReport,
              selectedContentId: $selectedContentId,
              userId: userId,
              reportCategory: .post)

          case .user:
            ProfileReportCommentView(
              memberContentViewModel: memberContentViewModel,
              goReport: $goReport,
              selectedContentId: $selectedContentId,
              reportCategory: .user,
              reportReason: reportReason ?? 0,
              userId: userId)
          }
        } label: {
          Text("다음")
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.Info)
        }
        .disabled(isSelected)
      }
      ToolbarItem(placement: .principal) {
        Text("콘텐츠 선택")
          .foregroundStyle(Color.labelColorPrimary)
          .font(.headline)
      }
    }
    .task {
      selectedIndex = reportCategory == .user ? -1 : 0
      await memberContentViewModel.requestMemberPostFeed(userID: userId)
    }
  }
}

extension ProfileReportContentSelectionView {
  @ViewBuilder
  func videoThumbnail(url: String, index: Int) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: url))
        .placeholder { // 플레이스 홀더 설정
          Color.black
        }
        .resizable()
        .scaledToFit()
      VStack {
        HStack {
          Spacer()
          Image(systemName: index == selectedIndex ? "checkmark.circle.fill" : "circle")
            .resizable()
            .scaledToFit()
            .foregroundColor(index == selectedIndex ? .Primary_Default : .white)
            .frame(width: 22, height: 22)
            .padding(6)
        }
        Spacer()
      }
    }
    .frame(height: 204)
    .cornerRadius(12)
  }
}
