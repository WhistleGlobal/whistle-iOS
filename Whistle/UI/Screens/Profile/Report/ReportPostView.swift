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
  @EnvironmentObject var apiViewModel: APIViewModel
  @State var isSelected = false
  @State var selectedIndex = 0
  @State var dummySet: [Color] = [Color.blue, Color.red, Color.green, Color.Blue_Pressed]
  @Binding var goReport: Bool
  let userId: Int
  let reportCategory: ReportUserView.ReportCategory

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 20) {
          ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index, content in
            if let url = content.videoUrl {
              Button {
                selectedIndex = index
              } label: {
                videoThumbnail(url: url, index: index)
                  .onAppear {
                    log(url)
                  }
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
        Text("게시물 선택")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        NavigationLink {
          switch reportCategory {
          case .post:
            ReportReasonView(goReport: $goReport, userId: userId, reportCategory: .post)
          case .user:
            ReportDetailView(goReport: $goReport)
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
    .navigationDestination(isPresented: .constant(false)) {
      ReportDetailView(goReport: $goReport)
    }
  }
}

extension ReportPostView {

  @ViewBuilder
  func videoThumbnail(url _: String, index: Int) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(.black)
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
    .frame(maxWidth: .infinity)
  }
}
