//
//  ProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
  let fontHeight = UIFont.preferredFont(forTextStyle: .title2).lineHeight
  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  @Binding var tabbarOpacity: Double

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("testCat")
          .resizable()
          .scaledToFill()
          .ignoresSafeArea()
          .blur(radius: 8)
      }
      VStack {
        Spacer().frame(height: 64)
        glassView(width: UIScreen.width - 32)
          .padding(.bottom, 12)
        HStack {
          Button {
            tabbarDirection = -1
          } label: {
            VStack {
              Spacer()
              Image(systemName: "square.grid.2x2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
              Spacer()
            }
            .foregroundColor(tabbarDirection == -1 ? Color.White : Color.Gray30_Dark)
            .frame(maxWidth: .infinity)
          }
          Button {
            tabbarDirection = 1
          } label: {
            VStack {
              Spacer()
              Image(systemName: "bookmark.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
              Spacer()
            }
            .foregroundColor(tabbarDirection == 1 ? Color.White : Color.Gray30_Dark)
            .frame(maxWidth: .infinity)
          }
        }
        .frame(height: 48)
        Rectangle()
          .foregroundColor(Color.Gray30_Dark)
          .frame(height: 1)
          .overlay {
            Capsule()
              .foregroundColor(Color.White)
              .frame(width: (UIScreen.width - 32) / 2, height: 5)
              .offset(x: tabbarDirection * (UIScreen.width - 32) / 4)
          }
          .padding(.bottom, 16)
        ScrollView {
          LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0 ..< 20) { _ in
              videoThumbnailView()
            }
          }
        }
        Spacer()
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea()
      VStack {
        Spacer()
        GlassBottomSheet(isShowing: $isShowingBottomSheet, content: AnyView(Text("Hi")))
          .animation(.easeIn(duration: 1.0), value: tabbarOpacity)
          .onChange(of: isShowingBottomSheet) { newValue in
            if !newValue {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tabbarOpacity = 1
              }
            }
          }
          // FIXME: - 기존 BottomSheet 처럼의 제스처 느낌이 아님
          .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
              .onEnded { value in
                if value.translation.height > 20 {
                  isShowingBottomSheet = false
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tabbarOpacity = 1
                  }
                }
              })
      }
      .ignoresSafeArea()
    }
  }
}

extension ProfileView {
  // FIXME: - 색상 적용 안됨
  @ViewBuilder
  func glassView(width: CGFloat, height: CGFloat = 338) -> some View {
    glassMorphicCard(width: width, height: height)
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(
            LinearGradient.Border_Glass,
            lineWidth: 2)
        profileInfo(height: height)
      }
  }

  @ViewBuilder
  func profileInfo(height: CGFloat) -> some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Button {
          self.tabbarOpacity = 0
          self.isShowingBottomSheet = true
        } label: {
          Circle()
            .foregroundColor(.Dim_Default)
            .frame(width: 48, height: 48)
            .padding(16)
            .overlay {
              Image(systemName: "ellipsis")
                .foregroundColor(Color.White)
                .fontWeight(.semibold)
            }
        }
      }
      // FIXME: - 프로필
      Circle()
        .frame(width: 100, height: 100)
        .overlay {
          VStack {
            Spacer()
            HStack {
              Spacer()
              RoundedRectangle(cornerRadius: 6)
                .foregroundColor(.Primary_Default)
                .frame(width: 24, height: 24)
                .overlay {
                  Image(systemName: "pencil.line")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 20)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                }
            }
          }
        }
        .padding(.bottom, 16)
      Text("UserName")
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
      Text("소개글 개글 개글 개구리")
        .foregroundColor(Color.LabelColor_Secondary_Dark)
        .fontSystem(fontDesignSystem: .body2_KO)
        .padding(.bottom, 16)
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(20)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
        }
        Rectangle().frame(width: 1, height: 36).foregroundColor(.white)
        VStack(spacing: 4) {
          Text("\(100)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
          Text("follower")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
        }
      }
      Spacer()
    }
    .frame(height: height)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  func videoThumbnailView() -> some View {
    Rectangle()
      .frame(height: 204)
      .foregroundColor(.black)
      .cornerRadius(12)
      .overlay {
        VStack {
          Spacer()
          HStack(spacing: 4) {
            Image(systemName: "play.circle.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 17, height: 17)
              .foregroundColor(.Primary_Default)
            Text("367.5K")
              .fontSystem(fontDesignSystem: .caption_KO_Semibold)
              .foregroundColor(Color.LabelColor_Primary_Dark)
          }
          .padding(.bottom, 8.5)
          .padding(.leading, 8)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
  }
}
