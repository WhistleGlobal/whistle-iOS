//
//  SEMemberProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/11/23.
//

import _AVKit_SwiftUI
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - SEMemberProfileView

struct SEMemberProfileView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared

  @State var isFollow = false
  @State var goReport = false
  @State var showDialog = false
  @State var offsetY: CGFloat = 0

  @Binding var players: [AVPlayer?]
  @Binding var currentIndex: Int

  let userId: Int
  let processor = BlurImageProcessor(blurRadius: 10)

  var body: some View {
    ZStack {
      Color.clear.overlay {
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
        Spacer().frame(height: topSpacerHeight)
        glassProfile(
          cornerRadius: profileCornerRadius,
          overlayed: profileInfo())
          .frame(height: 278 + (146 * progress) + profileHeightLast)
          .padding(.bottom, 8)
          .padding(.horizontal, profileHorizontalPadding)
          .zIndex(1)
        if apiViewModel.memberFeed.isEmpty {
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
                  MemberFeedView(currentIndex: index)
                    .environmentObject(apiViewModel)
                    .id(UUID())
                } label: {
                  videoThumbnailView(
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    viewCount: content.contentViewCount ?? 0)
                }
                .id(UUID())
              }
            }
            .padding(.horizontal, 16)
            .offset(y: videoOffset)
            .offset(coordinateSpace: .named("SCROLL")) { offset in
              offsetY = offset
            }
            Spacer().frame(height: 800)
          }
          .scrollIndicators(.hidden)
          .coordinateSpace(name: "SCROLL")
          .zIndex(0)
          Spacer()
        }
      }
      .ignoresSafeArea()
    }
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $showDialog) {
      if apiViewModel.myProfile.userId != userId {
        Button(apiViewModel.memberProfile.isBlocked ? "차단 해제" : "차단", role: .destructive) {
          if apiViewModel.memberProfile.isBlocked {
            alertViewModel.linearAlert(
              title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
              content: "이제 상대방이 회원님의 게시물을 보거나 팔로우할 수 있습니다. 상대방에게 회원님이 차단을 해제했다는 정보를 알리지 않습니다.",
              destructiveText: "차단해제")
            {
              toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단 해제되었습니다.")
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
              title: "\(apiViewModel.memberProfile.userName) 님을 차단하시겠어요?",
              content: "차단된 사람은 회원님의 프로필 또는 콘텐츠를 찾을 수 없게 되며, 상대방에게 차단되었다는 알림이 전송되지 않습니다.",
              destructiveText: "차단")
            {
              toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단되었습니다.")
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
        }
        Button("신고", role: .destructive) {
          goReport = true
        }
      }
      Button("프로필 URL 복사", role: .none) {
        UIPasteboard.general.setValue(
          "https://readywhistle.com/profile_uni?id=\(userId)",
          forPasteboardType: UTType.plainText.identifier)
        toastViewModel.toastInit(message: "클립보드에 복사되었습니다")
      }
      Button("취소", role: .cancel) { }
    }
    .fullScreenCover(isPresented: $goReport) {
      ProfileReportTypeSelectionView(goReport: $goReport, userId: userId)
        .environmentObject(apiViewModel)
    }
    .task {
      await apiViewModel.requestMemberProfile(userID: userId)
      await apiViewModel.requestMemberFollow(userID: userId)
      await apiViewModel.requestMemberWhistlesCount(userID: userId)
      isFollow = apiViewModel.memberProfile.isFollowed
    }
    .task {
      await apiViewModel.requestMemberPostFeed(userID: userId)
    }
    .onAppear {
      if !players.isEmpty {
        players[currentIndex]?.pause()
      }
    }
  }
}

extension SEMemberProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 48)
      profileImageView(url: apiViewModel.memberProfile.profileImg, size: profileImageSize)
        .padding(.bottom, 12)
      Text(apiViewModel.memberProfile.userName)
        .font(.system(size: 18, weight: .semibold).width(.expanded))
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .frame(height: 28)
      Spacer().frame(minHeight: 10)
      Color.clear.overlay {
        Text(apiViewModel.memberProfile.introduce ?? "")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .font(.system(size: 14, weight: .regular))
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(nil)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
      }
      .frame(height: introduceHeight) // 20 max
      .padding(.bottom, 8)
      .padding(.horizontal, 48)
      Spacer()
      if apiViewModel.memberProfile.isBlocked {
        Button {
          alertViewModel.linearAlert(
            title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
            content: "이제 상대방이 회원님의 게시물을 보거나 팔로우할 수 있습니다. 상대방에게 회원님이 차단을 해제했다는 정보를 알리지 않습니다.",
            destructiveText: "차단해제")
          {
            toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단 해제되었습니다.")
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
        .padding(.bottom, 24)
      } else {
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
        .padding(.bottom, 16)
        .disabled(userId == apiViewModel.myProfile.userId)
      }
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.memberWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .font(.system(size: 16, weight: .semibold).width(.expanded))
            .scaleEffect(whistleFollowerTextScale)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .font(.system(size: 10, weight: .semibold))
            .scaleEffect(whistleFollowerTextScale)
        }
        Rectangle().frame(width: 1, height: .infinity).foregroundColor(.white)
        NavigationLink {
          MemberFollowListView(userId: userId)
            .environmentObject(apiViewModel)
            .id(UUID())
        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.memberFollow.followerCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .font(.system(size: 16, weight: .semibold).width(.expanded))
              .scaleEffect(whistleFollowerTextScale)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .font(.system(size: 10, weight: .semibold))
              .scaleEffect(whistleFollowerTextScale)
          }
        }
        .id(UUID())
      }
      .frame(height: whistleFollowerTabHeight) // 42 max
      .padding(.bottom, 10)
      Spacer()
    }
    .frame(height: 278 + (146 * progress))
    .frame(maxWidth: .infinity)
    .overlay {
      VStack(spacing: 0) {
        HStack {
          Button {
            if !players.isEmpty {
              players[currentIndex]?.play()
            }
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(.white)
              .fontWeight(.semibold)
              .frame(width: 40, height: 40)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 40, height: 40))
          }
          Spacer()
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .foregroundColor(.white)
              .fontWeight(.semibold)
              .frame(width: 40, height: 40)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 40, height: 40))
          }
        }
        .offset(y: 28 - topSpacerHeight)
        .padding(.top, 16)
        .padding(.horizontal, 16 - profileHorizontalPadding)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
    }
  }

  @ViewBuilder
  func videoThumbnailView(thumbnailUrl: String, viewCount: Int) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: thumbnailUrl))
        .placeholder { // 플레이스 홀더 설정
          Color.black
        }
        .resizable()
        .scaledToFit()
      VStack {
        Spacer()
        HStack(spacing: 4) {
          Image(systemName: "play.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 17, height: 17)
            .foregroundColor(.Primary_Default)
          Text("\(viewCount)")
            .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            .foregroundColor(Color.LabelColor_Primary_Dark)
        }
        .padding(.bottom, 8.5)
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(height: UIScreen.getHeight(204))
    .cornerRadius(12)
  }

  @ViewBuilder
  var unblockButton: some View {
    Text("차단해제")
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

// MARK: - Sticky Header Computed Properties

extension SEMemberProfileView {
  var progress: CGFloat {
    -(offsetY / 132) > 1 ? -1 : (offsetY > 0 ? 0 : (offsetY / 132))
  }

  var progressOpacity: CGFloat {
    abs(1 + (progress * 1.5)) > 1 ? 0 : 1 + (progress * 1.5)
  }

  var profileHorizontalPadding: CGFloat {
    switch -offsetY {
    case ..<0:
      16
    case 0 ..< 28:
      16 + (16 * (offsetY / 28))
    default:
      0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      32
    case 0 ..< 28:
      32 + (32 * (offsetY / 28))
    default:
      0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      28
    case 0 ..< 28:
      28 + offsetY
    default:
      0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      56
    case 0 ..< 68:
      56 + (56 * (offsetY / 68))
    default:
      0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<68:
      42
    case 68 ..< 126:
      42 + (42 * ((offsetY + 68) / 58))
    default:
      0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      1
    case 68 ..< 126:
      1 - abs((offsetY + 68) / 58)
    default:
      0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<126:
      36
    case 126 ..< 146:
      28 + (28 * ((offsetY + 126) / 20))
    default:
      0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<126:
      114
    case 126 ..< 146:
      79 + (79 * ((offsetY + 126) / 20))
    default:
      0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<126:
      1
    case 126 ..< 146:
      1 - abs((offsetY + 126) / 20)
    default:
      0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<146:
      20
    case 146 ..< 202:
      20 + (20 * ((offsetY + 146) / 56))
    default:
      0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<146:
      1
    case 146 ..< 202:
      1 - abs((offsetY + 146) / 56)
    default:
      0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<146:
      0
    case 146 ..< 202:
      32 * ((offsetY + 146) / 56)
    case 202...:
      -32
    default:
      0
    }
  }

  var tabPadding: CGFloat {
    switch -offsetY {
    case ..<146:
      16
    case 146 ..< 202:
      8 + (8 * ((offsetY + 146) / 56))
    case 202...:
      0
    default:
      0
    }
  }

  var tabHeight: CGFloat {
    switch -offsetY {
    case ..<146:
      48
    case 146 ..< 202:
      48 + (48 * ((offsetY + 146) / 56))
    case 202...:
      0
    default:
      0
    }
  }

  var videoOffset: CGFloat {
    offsetY < -202 ? 202 : -offsetY
  }

  var profileHeightLast: CGFloat {
    switch -offsetY {
    case ..<146:
      0
    case 146 ..< 202:
      (offsetY + 146) / 56 * 32
    case 202...:
      -32
    default:
      0
    }
  }
}
