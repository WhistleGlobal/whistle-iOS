//
//  MemberProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import _AVKit_SwiftUI
import BottomSheet
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - MemberProfileView

struct MemberProfileView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var alertViewModel = AlertViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared

  @State var isFollow = false
  @State var isProfileLoaded = false
  @State var goReport = false
  @State var bottomSheetPosition: BottomSheetPosition = .hidden

  @State var showDialog = false
  @State var offsetY: CGFloat = 0
  let userId: Int
  let processor = BlurImageProcessor(blurRadius: 10)

  var body: some View {
    ZStack {
      Color.clear
        .overlay {
          if let url = apiViewModel.memberProfile.profileImg, !url.isEmpty {
            KFImage.url(URL(string: url))
              .placeholder { _ in
                Image("BlurredDefaultBG")
                  .resizable()
                  .scaledToFill()
                  .ignoresSafeArea()
              }
              .resizable()
              .setProcessor(processor)
              .scaledToFill()
              .scaleEffect(2.0)
          } else {
            Image("BlurredDefaultBG")
              .resizable()
              .scaledToFill()
              .ignoresSafeArea()
          }
        }
      VStack {
        if UIScreen.main.nativeBounds.height == 1334 {
          Spacer().frame(height: topSpacerHeightSE * 2)
        } else {
          Spacer().frame(height: topSpacerHeight)
        }
        glassProfile(
          cornerRadius: profileCornerRadius,
          overlayed: profileInfo())
          .frame(height: UIScreen.getHeight(418 + (240 * progress) + profileHeightLast))
          .padding(.horizontal, profileHorizontalPadding)
          .zIndex(1)
          .padding(.bottom, 12)
        if apiViewModel.memberFeed.isEmpty {
          if !apiViewModel.memberProfile.isBlocked {
            Spacer()
            Image(systemName: "photo.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: 48)
              .foregroundColor(.LabelColor_Primary_Dark)
              .padding(.bottom, 24)
            Text("아직 콘텐츠가 없습니다.")
              .fontSystem(fontDesignSystem: .body1_KO)
              .foregroundColor(.LabelColor_Primary_Dark)
              .padding(.bottom, 76)
          } else {
            Spacer()
            Text("차단된 계정")
              .fontSystem(fontDesignSystem: .subtitle1_KO)
              .foregroundColor(.LabelColor_Primary_Dark)
            Text("사용자에 의해 차단된 계정입니다")
              .fontSystem(fontDesignSystem: .body1_KO)
              .foregroundColor(.LabelColor_Primary_Dark)
              .padding(.bottom, 56)
          }
          Spacer()
        } else {
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(Array(apiViewModel.memberFeed.enumerated()), id: \.element) { index, content in
                NavigationLink {
                  MemberFeedView(index: index, userId: apiViewModel.memberFeed[index].userId ?? 0)
                    .id(UUID())
                } label: {
                  videoThumbnailView(
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    whistleCount: content.whistleCount ?? 0,
                    isHated: content.isHated)
                }
                .id(UUID())
              }
            }
            .padding(.horizontal, 16)
            .offset(y: videoOffset)
            .offset(coordinateSpace: .named("SCROLL")) { offset in
              offsetY = offset
            }
            Spacer().frame(height: 1800)
          }
          .scrollIndicators(.hidden)
          .coordinateSpace(name: "SCROLL")
          .zIndex(0)
          Spacer()
        }
      }
      .ignoresSafeArea()
      if bottomSheetPosition != .hidden {
        DimmedBackground()
      }
    }
    .navigationBarBackButtonHidden()
    .fullScreenCover(isPresented: $goReport) {
      ProfileReportTypeSelectionView(goReport: $goReport, userId: userId)
        .environmentObject(apiViewModel)
    }
    .task {
      await apiViewModel.requestMemberProfile(userID: userId)
      isFollow = apiViewModel.memberProfile.isFollowed
      isProfileLoaded = true
      await apiViewModel.requestMemberFollow(userID: userId)
      await apiViewModel.requestMemberWhistlesCount(userID: userId)
    }
    .task {
      await apiViewModel.requestMemberPostFeed(userID: userId)
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(298)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text(CommonWords().more)
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.white)
          Spacer()
          Button {
            bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .foregroundColor(.white)
          }
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Rectangle().frame(width: UIScreen.width, height: 1).foregroundColor(Color.Border_Default_Dark)
        Button {
          bottomSheetPosition = .hidden
          if apiViewModel.memberProfile.isBlocked {
            alertViewModel.linearAlert(
              isRed: true,
              title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
              content: AlertContents().unblock,
              destructiveText: CommonWords().unblock)
            {
              toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단 해제되었습니다")
              Task {
                await apiViewModel.blockAction(userID: userId, method: .delete)
                BlockList.shared.userIds.append(userId)
                BlockList.shared.userIds = BlockList.shared.userIds.filter { $0 != userId }
                Task {
                  await apiViewModel.requestMemberProfile(userID: userId)
                  await apiViewModel.requestMemberPostFeed(userID: userId)
                }
                Task {
                  await apiViewModel.requestMemberFollow(userID: userId)
                  await apiViewModel.requestMemberWhistlesCount(userID: userId)
                }
              }
            }
          } else {
            alertViewModel.linearAlert(
              isRed: true,
              title: "\(apiViewModel.memberProfile.userName) 님을 차단하시겠어요?",
              content: AlertContents().block,
              cancelText: CommonWords().cancel,
              destructiveText: CommonWords().block)
            {
              toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단되었습니다")
              Task {
                await apiViewModel.blockAction(userID: userId, method: .post)
                BlockList.shared.userIds.append(userId)
                Task {
                  await apiViewModel.requestMemberProfile(userID: userId)
                  await apiViewModel.requestMemberPostFeed(userID: userId)
                }
                Task {
                  await apiViewModel.requestMemberFollow(userID: userId)
                  await apiViewModel.requestMemberWhistlesCount(userID: userId)
                }
              }
            }
          }
        } label: {
          bottomSheetRowWithIcon(
            systemName: "nosign",
            text: apiViewModel.memberProfile.isBlocked ? CommonWords().unblockAction : CommonWords().blockAction)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        Button {
          bottomSheetPosition = .hidden
          goReport = true
        } label: {
          bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: CommonWords().reportAction)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        Button {
          bottomSheetPosition = .hidden
          let shareURL = URL(
            string: "https://readywhistle.com/profile_uni?id=\(userId)")!
          let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
          UIApplication.shared.windows.first?.rootViewController?.present(
            activityViewController,
            animated: true,
            completion: nil)
        } label: {
          bottomSheetRowWithIcon(systemName: "square.and.arrow.up", text: CommonWords().shareProfile)
        }
        Spacer()
      }
      .frame(height: 298)
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
        })
    .onDismiss {
      tabbarModel.tabbarOpacity = 1.0
    }
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
  }
}

extension MemberProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      if UIScreen.main.nativeBounds.height == 1334 {
        Spacer().frame(height: topSpacerHeightSE + 20)
      } else {
        Spacer().frame(height: UIScreen.getHeight(64))
      }
      profileImageView(
        url: apiViewModel.memberProfile.profileImg,
        size: UIScreen.getHeight(profileImageSize))
        .padding(.bottom, UIScreen.getHeight(16))
      Text(apiViewModel.memberProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .offset(y: usernameOffset)
      Spacer()
      Color.clear.overlay {
        Text(apiViewModel.memberProfile.introduce ?? "")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(2)
          .truncationMode(.tail)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
          .padding(.bottom, UIScreen.getHeight(16))
      }
      .frame(height: UIScreen.getHeight(introduceHeight))
      .padding(.horizontal, UIScreen.getWidth(48))
      if apiViewModel.memberProfile.isBlocked {
        Button {
          alertViewModel.linearAlert(
            isRed: true,
            title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
            content: AlertContents().block,
            cancelText: CommonWords().cancel,
            destructiveText: CommonWords().unblock)
          {
            toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단 해제되었습니다")
            Task {
              await apiViewModel.blockAction(userID: userId, method: .delete)
              BlockList.shared.userIds.append(userId)
              BlockList.shared.userIds = BlockList.shared.userIds.filter { $0 != userId }
              Task {
                await apiViewModel.requestMemberProfile(userID: userId)
                await apiViewModel.requestMemberPostFeed(userID: userId)
              }
              Task {
                await apiViewModel.requestMemberFollow(userID: userId)
                await apiViewModel.requestMemberWhistlesCount(userID: userId)
              }
            }
          }
        } label: {
          unblockButton
        }
        .padding(.bottom, UIScreen.getHeight(24))
      } else {
        Capsule()
          .frame(width: UIScreen.getWidth(112), height: UIScreen.getHeight(36))
          .foregroundColor(isProfileLoaded ? .clear : .Gray_Default)
          .overlay {
            Button("") {
              Task {
                if isFollow {
                  isFollow.toggle()
                  await apiViewModel.followAction(userID: userId, method: .delete)
                } else {
                  isFollow.toggle()
                  await apiViewModel.followAction(userID: userId, method: .post)
                }
              }
            }
            .buttonStyle(FollowButtonStyle(isFollowed: $isFollow))
            .scaleEffect(profileEditButtonScale)
            .opacity(isProfileLoaded ? 1 : 0)
            .disabled(userId == apiViewModel.myProfile.userId)
          }
          .padding(.bottom, UIScreen.getHeight(24))
          .scaleEffect(profileEditButtonScale)
      }
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          if apiViewModel.memberProfile.isBlocked {
            Text("0")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
          } else {
            Text("\(apiViewModel.memberWhistleCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
          }
          Text(CommonWords().whistle)
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .scaleEffect(whistleFollowerTextScale)
        }
        .hCenter()
        Rectangle().frame(width: 1).foregroundColor(.white).scaleEffect(0.5)
        NavigationLink {
          MemberFollowListView(userId: userId)
            .environmentObject(apiViewModel)
            .id(UUID())
        } label: {
          VStack(spacing: 4) {
            if apiViewModel.memberProfile.isBlocked {
              Text("0")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
                .scaleEffect(whistleFollowerTextScale)
            } else {
              Text("\(apiViewModel.memberFollow.followerCount)")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
                .scaleEffect(whistleFollowerTextScale)
            }
            Text(CommonWords().follower)
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .scaleEffect(whistleFollowerTextScale)
          }
          .hCenter()
        }
        .disabled(apiViewModel.memberProfile.isBlocked)
        .id(UUID())
      }
      .frame(height: UIScreen.getHeight(whistleFollowerTabHeight))
      Spacer()
    }
    .frame(height: UIScreen.getHeight(418 + (240 * progress) + profileHeightLast))
    .frame(maxWidth: .infinity)
    .overlay {
      VStack(spacing: 0) {
        HStack {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(.white)
              .fontWeight(.semibold)
              .frame(width: 48, height: 48)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 48, height: 48))
          }
          Spacer()
          Button {
            bottomSheetPosition = .absolute(298)
          } label: {
            Image(systemName: "ellipsis")
              .foregroundColor(.white)
              .fontWeight(.semibold)
              .frame(width: 48, height: 48)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 48, height: 48))
          }
        }
        .offset(
          y: UIScreen.main.nativeBounds.height == 1334
            ? UIScreen.getHeight(20 - topSpacerHeightSE)
            : UIScreen.getHeight(64 - topSpacerHeight))
          .padding(.horizontal, 16 - profileHorizontalPadding)
        Spacer()
      }
      .padding(16)
    }
  }

  @ViewBuilder
  func videoThumbnailView(thumbnailUrl: String, whistleCount: Int, isHated: Bool) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: thumbnailUrl))
        .placeholder { // 플레이스 홀더 설정
          Color.black
        }
        .resizable()
        .scaledToFit()
        .blur(radius: isHated ? 30 : 0, opaque: false)
        .scaleEffect(isHated ? 1.3 : 1)
        .overlay {
          if isHated {
            Image(systemName: "eye.slash.fill")
              .font(.system(size: 30))
              .foregroundColor(.Gray10)
          }
        }
      VStack {
        Spacer()
        HStack(spacing: 4) {
          Image(systemName: "heart.fill")
            .font(.system(size: 16))
            .foregroundColor(.Danger)
          Text("\(whistleCount)")
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .foregroundColor(Color.LabelColor_Primary_Dark)
        }
        .padding(.bottom, 8.5)
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(width: UIScreen.getWidth(204 * 9 / 16), height: UIScreen.getHeight(204))
    .cornerRadius(12)
  }

  @ViewBuilder
  var unblockButton: some View {
    Text(CommonWords().unblock)
      .fontSystem(fontDesignSystem: .subtitle3_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.horizontal, 20)
      .padding(.vertical, 6)
      .background {
        Capsule()
          .foregroundColor(.Primary_Default)
      }
  }
}

extension MemberProfileView {
  var progress: CGFloat {
    -(offsetY / 177) > 1 ? -1 : (offsetY > 0 ? 0 : (offsetY / 177))
  }

  var progressOpacity: CGFloat {
    abs(1 + (progress * 1.5)) > 1 ? 0 : 1 + (progress * 1.5)
  }

  var profileHorizontalPadding: CGFloat {
    switch -offsetY {
    case ..<0:
      16
    case 0 ..< 64:
      16 + (16 * (offsetY / 64))
    default:
      0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      32
    case 0 ..< 64:
      32 + (32 * (offsetY / 64))
    default:
      0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      64
    case 0 ..< 64:
      64 + offsetY
    default:
      0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      100
    case 0 ..< 122:
      100 + (100 * (offsetY / 122))
    default:
      0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<122:
      54
    case 122 ..< 200:
      54 + (54 * ((offsetY + 122) / 78))
    default:
      0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      1
    case 122 ..< 200:
      1 - abs((offsetY + 122) / 78)
    default:
      0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<200:
      36
    case 200 ..< 252:
      36 + (36 * ((offsetY + 200) / 52))
    default:
      0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<200:
      114
    case 200 ..< 252:
      114 + (114 * ((offsetY + 200) / 52))
    default:
      0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<200:
      1
    case 200 ..< 252:
      1 - abs((offsetY + 200) / 52)
    default:
      0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<252:
      20
    case 252 ..< 305:
      20 + (20 * ((offsetY + 252) / 53))
    default:
      0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<252:
      1
    case 252 ..< 305:
      1 - abs((offsetY + 252) / 53)
    default:
      0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      0
    case 252 ..< 305:
      offsetY + 252
    case 305...:
      -60
    default:
      0
    }
  }

  var profileHeightLast: CGFloat {
    switch -offsetY {
    case ..<252:
      0
    case 252 ..< 305:
      (offsetY + 252) / 53 * 36
    case 305...:
      -36
    default:
      0
    }
  }

  var videoOffset: CGFloat {
    offsetY < -305 ? 305 : -offsetY
  }

  var topSpacerHeightSE: CGFloat {
    switch -offsetY {
    case ..<0:
      20
    case 0 ..< 20:
      20 + offsetY
    default:
      0
    }
  }

  var usernameOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      0
    case 252 ..< 305:
      -20 * ((offsetY + 252) / 53)
    default:
      20
    }
  }
}
