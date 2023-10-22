//
//  ReportPostView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import Kingfisher
import SwiftUI

// MARK: - ReportPostView

struct ReportPostView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @State var isSelected = false
  @State var selectedIndex = 0
  @Binding var selectedContentId: Int
  @State var dummySet: [Color] = [Color.blue, Color.red, Color.green, Color.Blue_Pressed]
  @Binding var goReport: Bool
  let userId: Int
  let reportCategory: ReportUserView.ReportCategory
  let reportReason: Int?

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 20) {
          ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index, content in
            if let url = content.thumbnailUrl {
              videoThumbnail(url: url, index: index)
                .onTapGesture {
                  selectedIndex = index
                  selectedContentId = apiViewModel.userPostFeed[index].contentId ?? 0
                }
            }
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("콘텐츠 선택")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        NavigationLink {
          switch reportCategory {
          case .post:
            ReportReasonView(
              goReport: $goReport,
              selectedContentId: $selectedContentId,
              userId: userId,
              reportCategory: .post)

          case .user:
            ReportDetailView(
              goReport: $goReport,
              selectedContentId: $selectedContentId,
              reportCategory: .user,
              reportReason: reportReason ?? 0,
              userId: userId)
          }
        } label: {
          Text("다음")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.Info)
        }
        .disabled(isSelected)
      }
    }
    .task {
      await apiViewModel.requestUserPostFeed(userId: userId)
    }
  }
}

extension ReportPostView {
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
            .foregroundColor(index == selectedIndex ? .Primary_Default : .White)
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
