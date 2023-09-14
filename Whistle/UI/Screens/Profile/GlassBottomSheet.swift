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
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var userAuth: UserAuth
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
          .frame(height: 450)
          .transition(.move(edge: .bottom))
          .background(Color.clear)
          .overlay {
            glassMoriphicView(width: UIScreen.width, height: 450, cornerRadius: 24)
              .offset(y: 20)
            RoundedRectangle(cornerRadius: 24)
              .stroke(lineWidth: 1)
              .foregroundStyle(
                LinearGradient.Border_Glass)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .offset(y: 20)
            VStack(spacing: 0) {
              Capsule()
                .frame(width: 36, height: 5)
                .foregroundColor(Color.Border_Default_Dark)
                .padding(.top, 5)
                .padding(.bottom, 4)
              HStack {
                Text("설정")
                  .fontSystem(fontDesignSystem: .subtitle1_KO)
                  .foregroundColor(.White)
              }
              .frame(height: 52)
              Divider().background(Color("Gray10"))
              NavigationLink {
                ProfileNotiView(isShowingBottomSheet: $isShowing)
                  .environmentObject(apiViewModel)
              } label: {
                bottomSheetRowWithIcon(systemName: "bell", iconWidth: 22, iconHeight: 20, text: "알림")
              }
              NavigationLink {
                ProfileInfoView(isShowingBottomSheet: $isShowing)
                  .environmentObject(apiViewModel)
              } label: {
                bottomSheetRowWithIcon(systemName: "info.circle", iconWidth: 22, iconHeight: 20, text: "약관 및 정책")
              }
              Button {
                log("공유")
              } label: {
                bottomSheetRowWithIcon(systemName: "square.and.arrow.up", iconWidth: 22, iconHeight: 20, text: "프로필 공유")
              }
              NavigationLink {
                ProfileReportView(isShowingBottomSheet: $isShowing)
                  .environmentObject(apiViewModel)
              } label: {
                bottomSheetRowWithIcon(
                  systemName: "exclamationmark.triangle.fill",
                  iconWidth: 22,
                  iconHeight: 20,
                  text: "신고")
              }
              Divider().background(Color("Gray10"))
              Group {
                Button {
                  log("로그아웃")
                  userAuth.appleSignout()
                } label: {
                  bottomSheetRow(text: "로그아웃", color: Color.Info)
                }
                Button {
                  log("계정삭제")
                } label: {
                  bottomSheetRow(text: "계정삭제", color: Color.Danger)
                }
              }
              Spacer()
            }
            .offset(y: 20)
          }
          .offset(y: isShowing ? 0 : 450)
      }
      .ignoresSafeArea()
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .ignoresSafeArea()
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
