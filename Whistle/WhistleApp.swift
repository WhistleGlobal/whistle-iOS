//
//  WhistleApp.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import KeychainSwift
import SwiftUI

// MARK: - WhistleApp

@main
struct WhistleApp: App {

  // MARK: Lifecycle

  init() {
    Font.registerFonts(fontName: "SF-Pro-Display-Semibold")
    Font.registerFonts(fontName: "SF-Pro-Text-Regular")
    Font.registerFonts(fontName: "SF-Pro-Text-Semibold")
    Font.registerFontsTTF(fontName: "SF-Pro")
  }

  // MARK: Internal

  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var userAuth = UserAuth()
  @State var testBool = false
  let keychain = KeychainSwift()

  var body: some Scene {
    WindowGroup {
      NavigationStack {
//        if userAuth.isAccess {
//          TabbarView()
//        } else {
//          SignInView()
//        }
        APITestView()
      }
      .tint(.black)
      .onAppear {
        if userAuth.isAccess {
          userAuth.loadData { }
        }
      }
    }
  }
}

public func log<T>(
  _ object: T?,
  filename: String = #file,
  line: Int = #line,
  funcName: String = #function)
{
  #if DEBUG
  if let obj = object {
    print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : \(obj)")
  } else {
    print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : nil")
  }
  #endif
}
