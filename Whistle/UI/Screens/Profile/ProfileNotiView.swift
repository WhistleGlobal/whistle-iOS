//
//  ProfileNotiView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileNotiView: View {
  @Environment(\.dismiss) var dismiss
  @Binding var isShowingBottomSheet: Bool
  @State var isOn = true

  var body: some View {
    List {
      Toggle("모두 일시 중단", isOn: $isOn)
      Toggle("게시글 휘슬 알림", isOn: $isOn)
      Toggle("팔로워 알림", isOn: $isOn)
      Toggle("Whistle에서 보내는 알림", isOn: $isOn)
      Toggle("이메일 알림", isOn: $isOn)
    }
    .scrollDisabled(true)
    .foregroundColor(.LabelColor_Primary)
    .tint(.Primary_Default)
    .listStyle(.plain)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("알림")
    .onAppear {
      isShowingBottomSheet = false
    }
  }
}

#Preview {
  NavigationStack {
    ProfileNotiView(isShowingBottomSheet: .constant(false))
  }
}
