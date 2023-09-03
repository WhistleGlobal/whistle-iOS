//
//  ProfileAlert.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

struct ProfileAlert: View {
  var body: some View {
//      RoundedRectangle(cornerRadius: 14)
//        .frame(width: 270, height: 195)
//        .foregroundColor(Color.Gray30_Dark)
    VStack(spacing: 0) {
      Rectangle()
        .frame(width: 270, height: 151)
        .foregroundColor(Color.Gray30_Dark)
        .cornerRadius(14, corners: [.topLeft, .topRight])
      Divider().frame(width: 270)
      HStack(spacing: 0) {
        Rectangle()
          .frame(width: 135, height: 44)
          .foregroundColor(Color.Gray30_Dark)
          .cornerRadius(14, corners: [.bottomLeft])
        Divider().frame(height: 44)
        Rectangle()
          .frame(width: 135, height: 44)
          .foregroundColor(Color.Gray30_Dark)
          .cornerRadius(14, corners: [.bottomRight])
      }
    }
//    VStack(spacing: 0) {
//      Text("정말 사용자 ID를\n 변경하시겠습니까?")
//            .foregroundColor(.white)
//      Text("30일마다 한 번씩 사용자 ID를\n 변경할 수 있습니다.")
//            .foregroundColor(.white)
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  ProfileAlert()
}
