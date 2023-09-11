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

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var userAuth = UserAuth()
  @StateObject var apiViewModel = APIViewModel()
  @State var testBool = false
  let keychain = KeychainSwift()

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        if userAuth.isAccess {
//          MusicListView()
          TabbarView()
            .environmentObject(apiViewModel)
        } else {
          SignInView()
        }
      }
      .tint(.black)
      .task {
        if userAuth.isAccess {
          userAuth.loadData {
            log("after Login")
          }
        }
      }
    }
  }
}

// MARK: - AppDelegate

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  @AppStorage("deviceToken") var deviceToken: String?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    // APNS 설정
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) {
        [weak self] granted, _ in
        log("Permission granted: \(granted)")
      }
    // APNS 등록
    application.registerForRemoteNotifications()
    return true
  }

  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    log("Failed to register for notifications: \(error.localizedDescription)")
  }

  // 성공시
  func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    log("Device Token: \(token)")
    self.deviceToken = token
    log("Device Token in appstorage: \(self.deviceToken)")
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
