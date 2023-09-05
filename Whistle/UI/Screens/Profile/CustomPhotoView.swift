//
//  CustomPhotoView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import SwiftUI

// MARK: - CustomPhotoView

struct CustomPhotoView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var photoViewModel: PhotoViewModel
  @State var showAlbumList = false
  @State var selectedImage: Image?
  @State var albumName = "최근 항목"

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
          photoViewModel.fetchPhotosWorkItem?.cancel()
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
          photoViewModel.fetchPhotosWorkItem?.cancel()
          dismiss()
        } label: {
          Text("완료")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.Info)
        }
      }
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .background(.white)
      .padding(.horizontal, 16)
      invertedCircleMask()
      photoView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .fullScreenCover(isPresented: $showAlbumList) {
      CustomAlbumListView(albumName: $albumName)
        .environmentObject(photoViewModel)
    }
  }
}

#Preview {
  CustomPhotoView()
}

extension CustomPhotoView {

  @ViewBuilder
  func invertedCircleMask() -> some View {
    if let selectedImage {
      Color.clear.overlay {
        selectedImage
          .resizable()
          .scaledToFill()
          .frame(width: 393,height: 393)
          .opacity(0.4)
        Circle()
          .frame(width: 393,height: 393)
          .blendMode(.destinationOut)
        selectedImage
          .resizable()
          .scaledToFill()
          .frame(width: 393,height: 393)
          .clipShape(Circle())
      }
      .frame(width: 393,height: 393)
      .clipShape(Rectangle())
      .compositingGroup()
    } else {
      // 가장 최근 이미지로 대체하기
      Color.black
        .frame(width: 393,height: 393)
    }
  }

  @ViewBuilder
  func photoView() -> some View {
    // MARK: - Image & Image List
    HStack(spacing: 8) {
      Button {
        photoViewModel.fetchPhotosWorkItem?.cancel()
        photoViewModel.listAlbums()
        showAlbumList = true
      } label: {
        Text(albumName)
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.LabelColor_Primary)
        Image(systemName: "chevron.down")
      }
      Spacer()
    }
    .frame(height: 54)
    .frame(maxWidth: .infinity)
    .background(.white)
    .padding(.horizontal, 16)
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

  @ViewBuilder
  func albumList() -> some View {
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
}
