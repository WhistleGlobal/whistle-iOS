//
//  AccessView.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import SwiftUI

struct AccessView: View {
  var body: some View {
    ZStack {
      Image("AccessBackground")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)

      glassMoriphicView(width: UIScreen.width-32, height: 56, cornerRadius: 12)
      
    }
  }
}

#Preview {
  AccessView()
}
