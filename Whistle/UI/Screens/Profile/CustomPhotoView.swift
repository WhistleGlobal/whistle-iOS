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
  @EnvironmentObject var apiViewModel: APIViewModel
  @State var showAlbumList = false
  @State var selectedImage: UIImage?
  @State var albumName = "최근 항목"
  @State var offsetY = 0.0
  @State var page = 1
  // Image crop properties

  var crop: Crop = .circle

  @State private var scale: CGFloat = 1
  @State private var lastScale: CGFloat = 0
  @State private var offset: CGSize = .zero
  @State private var lastStoredOffset: CGSize = .zero
  @GestureState private var isInteracting = false

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
          guard let selectedImage else {
            dismiss()
            return
          }
          Task {
            let renderer = ImageRenderer(content: cropImageView(true))
            renderer.scale = 0.5
            renderer.proposedSize = .init(crop.size())
            guard let image = renderer.uiImage else {
              log("Fail to render image")
              return
            }
            await apiViewModel.uploadPhoto(image: image) { url in log(url) }
            await apiViewModel.requestMyProfile()
            dismiss()
          }
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
      .zIndex(1)

      cropImageView()
        .frame(width: UIScreen.width, height: UIScreen.width)
        .zIndex(0)
      photoView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .fullScreenCover(isPresented: $showAlbumList) {
      CustomAlbumListView(albumName: $albumName)
        .environmentObject(photoViewModel)
    }
  }
}

extension CustomPhotoView {

  @ViewBuilder
  func photoView() -> some View {
    // MARK: - Image & Image List
    HStack(spacing: 8) {
      Button {
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
            photoViewModel.fetchPhotoByLocalIdentifier(localIdentifier: photo.localIdentifier) { photo in
              selectedImage = photo?.photo
            }
          } label: {
            Color.clear.overlay {
              Image(uiImage: photo.photo)
                .resizable()
                .scaledToFill()
            }
            .frame(height: UIScreen.width / 4)
            .clipShape(Rectangle())
          }
        }
      }
      .offset(coordinateSpace: .named("photoscroll")) { offset in
        offsetY = offset
        if page < Int(offset / 1000) * -1 {
          log("page : \(page)")
          log("Int() \(Int(offset / 1000) * -1)")
          photoViewModel.fetchPhotos(startIndex: page * 100 + 1, endIndex: (page + 1) * 100)
          page = Int(offset / 1000) * -1
        }
      }
    }
    .coordinateSpace(name: "photoscroll")
    .onChange(of: offsetY) { newValue in
      log(newValue)
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

// MARK: - Crop

enum Crop: Equatable {
  case circle
  case square
  case custom(CGSize)

  func name() -> String {
    switch self {
    case .circle:
      return "Circle"
    case .square:
      return "Square"
    case .custom(let cGSize):
      return "Custom \(Int(cGSize.width))x\(Int(cGSize.height))"
    }
  }

  func size() -> CGSize {
    switch self {
    case .circle:
      return .init(width: UIScreen.width, height: UIScreen.width)
    case .square:
      return .init(width: UIScreen.width, height: UIScreen.width)
    case .custom(let cGSzie):
      return cGSzie
    }
  }
}

extension CustomPhotoView {
  @ViewBuilder
  func cropImageView(_: Bool = true) -> some View {
    let cropSize = crop.size()
    GeometryReader {
      let size = $0.size

      if let selectedImage {
        Image(uiImage: selectedImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .overlay {
            GeometryReader { proxy in
              let rect = proxy.frame(in: .named("CROPVIEW"))
              Color.clear
                .onChange(of: isInteracting) { newValue in

                  withAnimation(.easeInOut(duration: 0.2)) {
                    if rect.minX > 0 {
                      offset.width = (offset.width - rect.minX)
                      haptics(.medium)
                    }
                    if rect.minY > 0 {
                      offset.height = (offset.height - rect.minY)
                      haptics(.medium)
                    }
                    if rect.maxX < size.width {
                      offset.width = (rect.minX - offset.width)
                      haptics(.medium)
                    }
                    if rect.maxY < size.height {
                      offset.height = (rect.minY - offset.height)
                      haptics(.medium)
                    }
                  }

                  if !newValue {
                    lastStoredOffset = offset
                  }
                }
            }
          }
          .frame(size)
      }
    }
    .offset(offset)
    .scaleEffect(scale)
    .coordinateSpace(name: "CROPVIEW")
    .gesture(
      DragGesture()
        .updating($isInteracting, body: { _, out, _ in
          out = true
        })
        .onChanged { value in
          let translation = value.translation
          offset = CGSize(
            width: translation.width + lastStoredOffset.width,
            height: translation.height + lastStoredOffset.height)
        })
    .gesture(
      MagnificationGesture()
        .updating($isInteracting, body: { _, out, _ in
          out = true
        })
        .onChanged { value in
          let updatedScale = value + lastScale
          scale = (updatedScale < 1 ? 1 : updatedScale)
        }
        .onEnded { _ in
          withAnimation(.easeInOut(duration: 0.2)) {
            if scale < 1 {
              scale = 1
              lastScale = 0
            } else {
              lastScale = scale - 1
            }
          }
        })
    .frame(cropSize)
    .cornerRadius(crop == .circle ? cropSize.height / 2 : 0)
  }

  func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
  }
}

extension View {
  @ViewBuilder
  func frame(_ size: CGSize) -> some View {
    frame(width: size.width, height: size.height)
  }
}
