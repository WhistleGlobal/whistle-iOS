//
//  FollowView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import SwiftUI

// MARK: - FollowView

struct FollowView: View {

  // MARK: Public

  public enum profileTabStatus: String {
    case follower
    case following
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @State var tabStatus: profileTabStatus = .follower

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button("") {
          tabStatus = .follower
        }
        .buttonStyle(
          FollowTabbarStyle(followNum: 9, tab: profileTabStatus.follower.rawValue, selectedTab: $tabStatus))
        Button("") {
          tabStatus = .following
        }
        .buttonStyle(
          FollowTabbarStyle(followNum: 3, tab: profileTabStatus.following.rawValue, selectedTab: $tabStatus))
      }
      .frame(height: 48)
      personRow(isFollow: true)
      personRow(isFollow: false)
      Spacer()
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
        Text("Whistle")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
    }
  }
}

#Preview {
  NavigationStack {
    FollowView()
  }
}

extension FollowView {
  @ViewBuilder
  func personRow(isFollow: Bool) -> some View {
    HStack(spacing: 0) {
      Circle()
        .frame(width: 48, height: 48)
      VStack(spacing: 0) {
        Text("UserName")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.LabelColor_Primary)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text("Description")
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading, 16)
      Button("") {
        log("Button pressed")
      }
      .buttonStyle(FollowButtonStyle(isFollow: isFollow))
      Spacer()
    }
    .frame(height: 72)
    .frame(maxWidth: .infinity)
  }
    
    @ViewBuilder
    func followEmptyView() -> some View {
        VStack(spacing: 24) {
          Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .foregroundColor(.LabelColor_Primary)
          Text("아직 회원님을 팔로우하는 사람이 없습니다")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

