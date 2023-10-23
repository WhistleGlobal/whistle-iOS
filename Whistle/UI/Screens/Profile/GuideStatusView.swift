//
//  GuideStatusView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import Kingfisher
import SwiftUI

struct GuideStatusView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
//      if apiViewModel.reportedContent.isEmpty {
      if true {
        Text("회원님의 콘텐츠는\n 현재 영향을 받지 않습니다.")
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.LabelColor_Primary)
          .multilineTextAlignment(.center)
          .padding(.bottom, 12)
        Text("커뮤니티 가이드라인을 준수해주셔서 감사합니다.")
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
      } else {
        Divider()
        Group {
          Text(
            "회원님의 계정 또는 콘텐츠가 가이드라인을 준수하지 않아 Whistle이 적용한 조치를 확인해보세요. Whistle")
            + Text(" 가이드라인").underline().bold()
            + Text("을 살펴보고 콘텐츠가 가이드를 준수하는지 확인합니다.\n\n결정이 잘못되었다고 생각되는 경우 ")
            + Text("readywhistle@gmail.com").underline().bold()
            + Text("로 해당 내용을 알려주세요.")
        }
        .fontSystem(fontDesignSystem: .caption_Regular)
        .foregroundColor(.LabelColor_Secondary)
        .padding(.vertical, 12)
        Divider()
        List {
          ForEach(apiViewModel.reportedContent, id: \.self) { content in
            reportRow(title: content.userName, dateString: content.caption, imageUrl: content.thumbnailUrl)
              .listRowSeparator(.hidden)
          }
        }
        .listStyle(.plain)
      }
    }
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("가이드 상태")
    .task {
      if apiViewModel.reportedContent.isEmpty {
//        await apiViewModel.requestReportedFeed()
      }
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
    }
  }

  @ViewBuilder
  func reportRow(title: String, dateString: String, imageUrl: String) -> some View {
    HStack {
      KFImage.url(URL(string: imageUrl)!)
        .placeholder { // 플레이스 홀더 설정
          Rectangle()
            .foregroundColor(.black)
            .frame(width: 60, height: 60)
            .cornerRadius(8)
        }
        .resizable()
        .scaledToFill()
        .frame(width: 60, height: 60)
        .cornerRadius(8)

      VStack(spacing: 4) {
        Text(title)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(.black)
          .fontSystem(fontDesignSystem: .subtitle1_KO)
        Text(dateString)
          .frame(maxWidth: .infinity, alignment: .leading)
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
          .lineLimit(1)
      }
    }
  }
}
