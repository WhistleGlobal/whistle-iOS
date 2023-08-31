//
//  WhistleApp.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import SwiftUI

// MARK: - WhistleApp

@main
struct WhistleApp: App {
  init() {
    Font.registerFonts(fontName: "SF-Pro-Display-Semibold")
    Font.registerFonts(fontName: "SF-Pro-Text-Regular")
    Font.registerFonts(fontName: "SF-Pro-Text-Semibold")
    Font.registerFontsTTF(fontName: "SF-Pro")
  }

  var body: some Scene {
    WindowGroup {
//            ContentView()
      NavigationStack {
        TabbarView()
      }
      .tint(.black)
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
