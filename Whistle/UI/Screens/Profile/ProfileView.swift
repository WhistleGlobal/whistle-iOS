//
//  ProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import Kingfisher
import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {

  // MARK: Public

  public enum profileTabCase: String {
    case myVideo
    case favoriteVideo
  }

  // MARK: Internal

  let fontHeight = UIFont.preferredFont(forTextStyle: .title2).lineHeight
  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var tabSelection: profileTabCase = .myVideo
  // FIXME: - video 모델 목록 불러오기 수정
  @State var videos: [Any] = []
  @Binding var tabbarOpacity: Double
  @EnvironmentObject var apiViewModel: APIViewModel

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
        HStack(spacing: 0) {
          Button {
            tabSelection = .myVideo
          } label: {
            Color.gray
              .opacity(0.01)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .buttonStyle(ProfileTabItem(
            systemName: "square.grid.2x2.fill",
            tab: profileTabCase.myVideo.rawValue,
            selectedTab: $tabSelection))
          Button {
            tabSelection = .favoriteVideo
          } label: {
            Color.gray
              .opacity(0.01)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .buttonStyle(ProfileTabItem(
            systemName: "bookmark.fill",
            tab: profileTabCase.favoriteVideo.rawValue,
            selectedTab: $tabSelection))
        }
        .frame(height: 48)
        .padding(.bottom, 16)
        if videos.isEmpty {
          Spacer()
          Text("공유하고 싶은 첫번째 게시물을 업로드해보세요")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
          Button {
            log("dd")
          } label: {
            Text("업로드하러 가기")
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .frame(width: 142, height: 36)
          }
          .buttonStyle(ProfileEditButtonStyle())
          .padding(.bottom, 76)
          Spacer()
        } else {
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(0 ..< 20) { _ in
                videoThumbnailView()
              }
            }
          }
          Spacer()
        }
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea()
      VStack {
        Spacer()
        GlassBottomSheet(isShowing: $isShowingBottomSheet, content: AnyView(Text("Hi")))
          .environmentObject(apiViewModel)
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
                  withAnimation {
                    isShowingBottomSheet = false
                  }
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
  func glassView(width: CGFloat, height: CGFloat = 398) -> some View {
    glassMorphicCard(width: width, height: height)
      .overlay {
        Image("ProfileBorder")
          .resizable()
          .frame(width: .infinity, height: .infinity)
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
          withAnimation {
            self.isShowingBottomSheet = true
          }
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(Color.White)
            .fontWeight(.semibold)
            .frame(width: 48, height: 48)
            .background(
              Circle()
                .foregroundColor(.Gray_Default)
                .frame(width: 48, height: 48))
        }
      }
      .padding([.top, .horizontal], 16)
      // FIXME: - 프로필

      KFImage.url(URL(string: apiViewModel.myProfile.profileImage))
        .placeholder { // 플레이스 홀더 설정
          Image("ProfileDefault")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
        }
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 4)

      Text(apiViewModel.myProfile.introduce)
        .foregroundColor(Color.LabelColor_Secondary_Dark)
        .fontSystem(fontDesignSystem: .body2_KO)
        .padding(.bottom, 16)
      NavigationLink {
        ProfileEditView()
          .environmentObject(apiViewModel)
      } label: {
        Text("프로필 편집")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .frame(width: 114, height: 36)
      }
      .frame(width: 114, height: 36)
      .padding(.bottom, 24)
      .buttonStyle(ProfileEditButtonStyle())
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.myWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
        }
        Rectangle().frame(width: 1, height: 36).foregroundColor(.white)
        NavigationLink {
          FollowView()
            .environmentObject(apiViewModel)
        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.myFollow.followingCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
          }
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
