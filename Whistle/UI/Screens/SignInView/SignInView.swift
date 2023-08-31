//
//  SignInView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import _AuthenticationServices_SwiftUI
import Security
import SwiftUI
// MARK: - SignInView

struct SignInView: View {

  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var userAuth = UserAuth()

  var body: some View {
    VStack {
      SignInWithAppleButton(
        onRequest: appleSignInViewModel.configureRequest,
        onCompletion: appleSignInViewModel.handleResult)
        .frame(maxWidth: 300, maxHeight: 45)
    }
    .navigationDestination(isPresented: $appleSignInViewModel.gotoTab) {
      TabbarView()
    }
    .onAppear {
      if userAuth.isAccess {
        userAuth.loadData {
          appleSignInViewModel.gotoTab = true
        }
      }
    }
  }
}
