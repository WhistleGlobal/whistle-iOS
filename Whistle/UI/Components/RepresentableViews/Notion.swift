//
//  NotionWebView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/16/23.
//

import Combine
import SwiftUI
import UIKit
import WebKit

struct Notion: UIViewRepresentable {
  var urlToLoad: String
  func makeUIView(context _: Context) -> WKWebView {
    guard let url = URL(string: urlToLoad) else {
      return WKWebView()
    }
    let webview = WKWebView()
    webview.load(URLRequest(url: url))
    return webview
  }

  func updateUIView(_: WKWebView, context _: UIViewRepresentableContext<Notion>) { }
}
