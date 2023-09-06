//
//  GlassBottomSheet.swift
//  Whistle
//
//  Created by ChoiYujin on 8/30/23.
//

import SwiftUI

// MARK: - GlassBottomSheet

struct GlassBottomSheet: View {
  @Binding var isShowing: Bool
  @EnvironmentObject var userViewModel: UserViewModel
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
          .frame(height: 386)
          .transition(.move(edge: .bottom))
          .background(.clear)
          .overlay {
            glassMorphicCard(width: UIScreen.width, height: 386)
              .cornerRadius(24, corners: [.topLeft, .topRight])
              .offset(y: 20)
            RoundedRectangle(cornerRadius: 24)
              .stroke(
                Color.Border_Default,
                lineWidth: 1.5)
              .frame(height: 386)
              .offset(y: 20)
            VStack(spacing: 0) {
              Capsule()
                .frame(width: 36, height: 5)
                .foregroundColor(Color.Dim_Thin)
                .padding(.top, 5)
                .padding(.bottom, 20)
              NavigationLink {
                ProfileNotiView(isShowingBottomSheet: $isShowing)
              } label: {
                bottomSheetRowWithIcon(systemName: "bell", iconWidth: 23, iconHeight: 24, text: "알림")
              }
              NavigationLink {
                ProfileInfoView(isShowingBottomSheet: $isShowing)
                  .environmentObject(userViewModel)
              } label: {
                bottomSheetRowWithIcon(systemName: "info.circle", iconWidth: 24, iconHeight: 24, text: "정보")
              }
              NavigationLink {
                ProfileReportView(isShowingBottomSheet: $isShowing)
              } label: {
                bottomSheetRowWithIcon(
                  systemName: "exclamationmark.triangle.fill",
                  iconWidth: 24,
                  iconHeight: 24,
                  text: "신고")
              }
              Divider().background(Color("Gray10"))
              bottomSheetRow(text: "로그아웃", color: Color.Primary_Default)
              bottomSheetRow(text: "계정삭제", color: Color.Danger)
              Spacer()
            }
            .offset(y: 20)
          }
          .offset(y: isShowing ? 0 : 386)
      }
      .ignoresSafeArea()
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .ignoresSafeArea()
//    .animation(.easeInOut, value: isShowing)
  }
}

extension GlassBottomSheet {
  @ViewBuilder
  func bottomSheetRowWithIcon(
    systemName: String,
    iconWidth: CGFloat,
    iconHeight: CGFloat,
    text: String)
    -> some View
  {
    HStack(spacing: 12) {
      Image(systemName: systemName)
        .resizable()
        .scaledToFit()
        .frame(width: iconWidth, height: iconHeight)
        .foregroundColor(.white)

      Text(text)
        .foregroundColor(.white)
        .fontSystem(fontDesignSystem: .body1_KO)
      Spacer()
      Image(systemName: "chevron.forward")
        .resizable()
        .scaledToFit()
        .padding(.vertical, 2.5)
        .padding(.horizontal, 6)
        .frame(width: 24, height: 24)
        .foregroundColor(.white)
    }
    .frame(height: 56)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  func bottomSheetRow(text: String, color: Color) -> some View {
    HStack {
      Text(text)
        .foregroundColor(color)
        .fontSystem(fontDesignSystem: .body1_KO)
      Spacer()
      Image(systemName: "chevron.forward")
        .resizable()
        .scaledToFit()
        .padding(.vertical, 2.5)
        .padding(.horizontal, 6)
        .frame(width: 24, height: 24)
        .foregroundColor(.white)
    }
    .frame(height: 56)
    .padding(.horizontal, 16)
  }
}
