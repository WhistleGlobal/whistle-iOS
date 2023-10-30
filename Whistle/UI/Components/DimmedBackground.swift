//
//  DimmedBackground.swift
//  Whistle
//
//  Created by 박상원 on 10/30/23.
//

import SwiftUI

struct DimmedBackground: View {
  var body: some View {
    Color.gray80Light.opacity(0.84).ignoresSafeArea()
  }
}

#Preview {
  DimmedBackground()
}
