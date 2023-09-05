//
//  CustomPhotoView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import SwiftUI

struct CustomPhotoView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var photoViewModel: PhotoViewModel
  @State var showAlbumList = false
  @State var selectedImage: Image?

  let columns = [
    GridItem(.flexible(minimum: 40), spacing: 0),
    GridItem(.flexible(minimum: 40), spacing: 0),
    GridItem(.flexible(minimum: 40), spacing: 0),
    GridItem(.flexible(minimum: 40), spacing: 0),
  ]

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
      if let selectedImage {
        Color.clear.overlay {
          selectedImage
            .resizable()
            .scaledToFill()
            .frame(width: 393,height: 393)
            .clipShape(Rectangle())
        }
        .frame(width: 393,height: 393)
      } else {
        Color.black
          .frame(width: 393,height: 393)
      }
      HStack(spacing: 8) {
        Button {
          photoViewModel.listAlbums()
          showAlbumList = true
        } label: {
          Text("최근 항목")
          Image(systemName: "chevron.down")
        }
        Spacer()
      }
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .background(.white)
      ScrollView {
        LazyVGrid(columns: columns, spacing: 0) {
          ForEach(photoViewModel.photos) { photo in
            Button {
              selectedImage = photo.photo
            } label: {
              Color.clear.overlay {
                photo.photo
                  .resizable()
                  .scaledToFill()
              }
              .frame(height: UIScreen.width / 4)
              .clipShape(Rectangle())
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .fullScreenCover(isPresented: $showAlbumList) {
      CustomAlbumListView()
        .environmentObject(photoViewModel)
    }
  }
}

#Preview {
  CustomPhotoView()
}
