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
      Divider().frame(width: UIScreen.width)
      List(photoViewModel.albums, id: \.name) { album in
        HStack(spacing: 16) {
          Image(uiImage: album.thumbnail ?? UIImage())
            .resizable()
            .frame(width: 64, height: 64)
            .cornerRadius(8)
            .overlay {
              RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundColor(.Border_Default)
                .frame(width: 64, height: 64)
            }

          VStack(spacing: 0) {
            Text("\(album.name)")
              .fontSystem(fontDesignSystem: .subtitle1_KO)
              .foregroundColor(.LabelColor_Primary)
              .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(album.count)")
              .fontSystem(fontDesignSystem: .body1)
              .foregroundColor(.LabelColor_Secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .listRowSeparator(.hidden)
        .frame(height: 80)
      }
      .listStyle(.plain)
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  CustomAlbumListView()
}

