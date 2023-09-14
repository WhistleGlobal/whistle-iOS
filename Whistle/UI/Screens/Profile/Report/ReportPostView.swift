//
//  ReportPostView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ReportPostView

struct ReportPostView: View {

  @Environment(\.dismiss) var dismiss
  @State var isSelected = false

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 20) {
          ForEach([Color.blue, Color.red, Color.green], id: \.self) { content in
            Button {
              log("video clicked")
            } label: {
//                    videoThumbnailView(url: content.videoUrl ?? "", viewCount: content.contentViewCount ?? 0)
              Rectangle()
                .fill(content)
            }
          }
        }
      }
    }
    .padding(.horizontal, 16)
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
        Text("게시물 선택")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          log("다음")
        } label: {
          Text("다음")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.Info)
        }
        .disabled(isSelected)
      }
    }
  }
}

#Preview {
  ReportPostView()
}

extension ReportPostView { }
