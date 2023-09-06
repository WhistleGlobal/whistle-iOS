//
//  APITestView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import SwiftUI

struct APITestView: View {

  @StateObject var profileViewModel: UserViewModel = .init()

  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
      .task {
//        await profileViewModel.requestUserProfile(userId: 3)
//        await profileViewModel.requestMyWhistlesCount()
//        await profileViewModel.requestUserWhistlesCount(userId: 3)
//        await profileViewModel.requestMyFollow()
//        profileViewModel.requestMyPostFeed()
//        profileViewModel.requestUserPostFeed(userId: 3)
        profileViewModel.requestNotiSetting()
      }
  }
}

#Preview {
  APITestView()
}
