//
//  CustomAlbumListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import SwiftUI

struct CustomAlbumListView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var photoViewModel: PhotoViewModel


  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
        }
        Spacer()
        Text("갤러리")
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.LabelColor_Primary)
        Spacer()
        Button {
          dismiss()
        } label: {
          Text("완료")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.Info)
        }
      }
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .background(.white)
      List(photoViewModel.albums, id: \.name) { album in
        HStack {
          Image(uiImage: album.thumbnail ?? UIImage())
            .resizable()
            .frame(width: 100, height: 100)
          Text("\(album.name)")
        }
      }
      .listStyle(.plain)
    }
  }
}

#Preview {
  CustomAlbumListView()
}

