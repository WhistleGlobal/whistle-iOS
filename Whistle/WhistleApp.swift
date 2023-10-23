//
//  WhistleApp.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import GoogleSignIn
import KeychainSwift
import SwiftUI
import VideoPicker

// MARK: - WhistleApp

@main
struct WhistleApp: App {
  // MARK: Lifecycle

  // Layout Test
  init() {
    Font.registerFonts(fontName: "SF-Pro-Display-Semibold")
    Font.registerFonts(fontName: "SF-Pro-Text-Regular")
    Font.registerFonts(fontName: "SF-Pro-Text-Semibold")
    Font.registerFontsTTF(fontName: "SF-Pro")
    Font.registerFontsTTF(fontName: "Roboto-Medium")
  }

  // MARK: Internal

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var userAuth = UserAuth()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var universalRoutingModel: UniversalRoutingModel = .init()
  @State var testBool = false
  @AppStorage("isAccess") var isAccess = false
  let keychain = KeychainSwift()
  var domainURL: String {
    AppKeys.domainURL as! String
  }

  @State private var pickerOptions = PickerOptionsInfo()
  var body: some Scene {
    WindowGroup {
      if isAccess {
        RootTabView()
          .environmentObject(userAuth)
          .environmentObject(universalRoutingModel)
          .task {
            if isAccess {
              let updateAvailable = await apiViewModel.checkUpdateAvailable()
              if updateAvailable {
                await apiViewModel.requestVersionCheck()
              }
              appleSignInViewModel.userAuth.loadData { }
            }
          }
          .onOpenURL { url in
            var urlString = url.absoluteString
            urlString = urlString.replacingOccurrences(of: "\(domainURL)", with: "")
            if urlString.contains("/profile_uni?") {
              urlString = urlString.replacingOccurrences(of: "/profile_uni?id=", with: "")
              guard let userId = Int(urlString) else {
                return
              }
              universalRoutingModel.userId = userId
              universalRoutingModel.isUniversalProfile = true
            } else if urlString.contains("/content_uni?") {
              urlString = urlString.replacingOccurrences(of: "/content_uni?contentId=", with: "")
              guard let contentId = Int(urlString) else {
                return
              }
              universalRoutingModel.contentId = contentId
              universalRoutingModel.isUniversalContent = true
            }
          }
      } else {
        NavigationStack {
          SignInView()
            .environmentObject(userAuth)
            .environmentObject(universalRoutingModel)
            .task {
              let updateAvailable = await apiViewModel.checkUpdateAvailable()
              if updateAvailable {
                await apiViewModel.requestVersionCheck()
              }
            }
        }
        .tint(.black)
      }
    }
  }
}

// MARK: - AppDelegate

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  @AppStorage("deviceToken") var deviceToken = ""

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

// MARK: - UniversalRoutingModel

class UniversalRoutingModel: ObservableObject {
  @Published var isUniversalProfile = false
  @Published var isUniversalContent = false
  @Published var userId = 0
  @Published var contentId = 0
}
