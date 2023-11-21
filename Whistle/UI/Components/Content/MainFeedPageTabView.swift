//
//  MainFeedPageTabView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/21/23.
//

import SwiftUI

struct MainFeedPageTabView<Content: View>: View {
  @Binding var selection: Int
  let content: () -> Content
  var body: some View {
    GeometryReader { geo in
      ScrollView(.horizontal) {
        TabView(selection: $selection) {
          content()
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .transition(.slide)
      }
    }
  }

  init(selection: Binding<Int>, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    _selection = selection
  }
}
