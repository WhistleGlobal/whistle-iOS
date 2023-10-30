//
//  Tags.swift
//  Whistle
//
//  Created by 박상원 on 10/10/23.
//

import SwiftUI

struct Tags: View {
  let titleKey: String
  let editable: Bool
  let onDelete: () -> Void

  var body: some View {
    HStack(alignment: .center, spacing: 8) {
      Text("#\(titleKey)")
        .fontSystem(fontDesignSystem: .body1_KO)
        .frame(minWidth: UIScreen.getWidth(28))
        .lineLimit(1)
      if editable {
        Image(systemName: "x.circle.fill")
          .foregroundStyle(Color.Dim_Default)
          .font(.system(size: 18))
          .onTapGesture {
            onDelete()
          }
      }
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 12)
  }
}
