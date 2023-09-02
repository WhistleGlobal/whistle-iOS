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

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .frame(width: 361, height: 48)
      personRow(isFollow: true)
      personRow(isFollow: false)
      Spacer()
    }
    .padding(.horizontal, 16)
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
}

