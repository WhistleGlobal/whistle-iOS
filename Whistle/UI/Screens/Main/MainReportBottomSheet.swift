//
//  MainReportBottomSheet.swift
//  Whistle
//
//  Created by ChoiYujin on 9/18/23.
//

import SwiftUI

// MARK: - MainReportBottomSheet

struct MainReportBottomSheet: View {

  @Binding var isShowing: Bool
  @EnvironmentObject var apiViewModel: APIViewModel
  var content: AnyView

  var body: some View {
    ZStack(alignment: .bottom) {
      if isShowing {
        Color.black
          .opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            isShowing.toggle()
          }
      }
      VStack {
        Spacer()
        content
          .frame(height: UIScreen.height - 48)
          .transition(.move(edge: .bottom))
          .background(Color.clear)
          .overlay {
            glassMoriphicView(width: UIScreen.width, height: UIScreen.height - 48, cornerRadius: 24)
              .offset(y: 20)
            RoundedRectangle(cornerRadius: 24)
              .stroke(lineWidth: 1)
              .foregroundStyle(LinearGradient.Border_Glass)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .offset(y: 20)
            VStack(spacing: 0) {
              HStack {
                Button {
                  withAnimation {
                    isShowing = false
                  }
                } label: {
                  Color.clear
                    .frame(width: 25, height: 29)
                    .overlay {
                      Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(.Gray10)
                    }
                }
                Spacer()
                Text("신고")
                  .fontSystem(fontDesignSystem: .subtitle2_KO)
                  .foregroundColor(.Gray10)

                Spacer()
                Spacer().frame(width: 25, height: 29)
              }
              .padding(.horizontal, 16)
              .frame(height: 53)
              Divider().frame(maxWidth: .infinity)
                .padding(.bottom, 4)
              VStack(spacing: 10) {
                Text("이 콘텐츠를 신고하는 이유")
                  .fontSystem(fontDesignSystem: .subtitle2_KO)
                  .foregroundColor(.Gray10)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.horizontal, 16)
                Text("지식재산권 침해를 신고하는 경우를 제외하고 회원님의 신고는 익명으로 처리됩니다. 누군가 위급한 상황에 있다고 생각된다면 즉시 현지 응급 서비스 기관에 연락하시기 바랍니다.")
                  .fontSystem(fontDesignSystem: .caption_KO_Regular)
                  .foregroundColor(.Gray30)
                  .padding(.horizontal, 16)
              }
              .padding(.vertical, 16)
              Divider().frame(maxWidth: .infinity)
              ForEach(PostReportReason.allCases, id: \.rawValue) { reasonType in
                Button {
                  log("reportType : \(reasonType.description)")
                } label: {
                  listRow(reportType: reasonType)
                }
              }
              Spacer()
            }
            .frame(height: UIScreen.height - 48)
            .offset(y: 20)
          }
          .offset(y: isShowing ? 0 : UIScreen.height - 48)
      }
    }
  }
}

extension MainReportBottomSheet {

  @ViewBuilder
  func listRow(reportType: PostReportReason) -> some View {
    HStack {
      Text(reportType.rawValue)
        .fontSystem(fontDesignSystem: .body1_KO)
        .foregroundColor(.Gray10)
      Spacer()
      Color.clear
        .frame(width: 24, height: 24)
        .overlay {
          Image(systemName: "chevron.forward")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 19)
            .foregroundColor(.Gray30)
        }
    }
    .background(Color.clear)
    .padding(.horizontal, 16)
    .frame(height: 56)
  }
}

#Preview {
  MainReportBottomSheet(isShowing: .constant(true), content: AnyView(Text("")))
    .background {
      Image("testCat")
        .resizable()
        .scaledToFit()
    }
}
