//
//  CustomRefresh.swift
//  Whistle
//
//  Created by ChoiYujin on 11/8/23.
//

import Foundation
import SwiftUI

// MARK: - CustomRefreshView

struct CustomRefresh: View {
  var body: some View {
    VStack {
      ProgressView() // Custom refresh indicator
        .tint(Color.white) // Set the color to white
      Text("Pull to refresh")
        .foregroundColor(Color.white) // Set the text color to white
    }
  }
}
