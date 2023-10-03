//
//  NoSignInProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import BottomSheet
import SwiftUI

// MARK: - NoSignInProfileView

struct NoSignInProfileView: View {
  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
          .blur(radius: 50)
          .scaleEffect(1.4)
      }
      VStack(spacing: 0) {
        Spacer().frame(height: 64)
        glassProfile(
          width: UIScreen.width - 32,
          height: 340,
          cornerRadius: 32,
          overlayed: overlayedView())
          .padding(.bottom, 12)
        Spacer()
      }
    }
    .ignoresSafeArea()
  }
}

#Preview {
  NoSignInProfileView()
}

extension NoSignInProfileView {
  @ViewBuilder
  func overlayedView() -> some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Button { } label: {
          Circle()
            .foregroundColor(.Gray_Default)
            .frame(width: 48, height: 48)
            .overlay {
              Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.White)
                .fontWeight(.semibold)
                .frame(width: 20, height: 20)
            }
        }
      }
      .padding([.top, .horizontal], 16)
      Image("ProfileDefault")
        .resizable()
        .scaledToFit()
        .frame(height: 100)
        .padding(.bottom, 16)
      Text("로그인을 해주세요")
        .fontWeight(.semibold)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .foregroundColor(.LabelColor_Primary_Dark)
        .padding(4)
      Text("더 많은 스포츠 콘텐츠를 즐겨보세요")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary_Dark)
        .padding(.bottom, 24)
      Button { } label: {
        Text("가입하기")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.LabelColor_Primary_Dark)
          .frame(maxWidth: .infinity)
          .background {
            Capsule()
              .foregroundColor(.Blue_Default)
              .frame(width: .infinity, height: 48)
              .padding(.horizontal, 32)
          }
      }
      Spacer()
    }
  }
}
