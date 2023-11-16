//
//  ProfileImagePickerView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import Photos
import SwiftUI

// MARK: - ProfileImagePickerView

struct ProfileImagePickerView: View {

  @Environment(\.displayScale) private var displayScale
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @ObservedObject var photoCollection: PhotoCollection

  @State var selectedImage: UIImage?
  @State private var scale: CGFloat = 1
  @State private var lastScale: CGFloat = 0
  @State private var offset: CGSize = .zero
  @State private var lastStoredOffset: CGSize = .zero
  @State private var albumName = "최근 항목"
  @State var showAlbumList = false
  @GestureState private var isInteracting = false

  var crop: Crop = .circle
  private var imageSize: CGSize {
    CGSize(width: 800, height: 800)
  }

  private static let itemSize = CGSize(width: UIScreen.width / 4 - 1, height: UIScreen.width / 4 - 1)

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
            .font(.system(size: 20))
            .contentShape(Rectangle())
            .foregroundColor(.labelColorPrimary)
            .frame(width: 24, height: 24)
        }
        Spacer()
        Text(CommonWords().album)
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.labelColorPrimary)
        Spacer()
        Button {
          guard selectedImage != nil else {
            dismiss()
            return
          }
          Task {
            let renderer = ImageRenderer(content: cropImageView(true))
            renderer.scale = 0.5
            renderer.proposedSize = .init(crop.size())
            guard let image = renderer.uiImage else {
              return
            }
            await apiViewModel.uploadProfilePhoto(image: image) { _ in }
            await apiViewModel.requestMyProfile()
            toastViewModel.toastInit(message: ToastMessages().profileImageUpdated, padding: 32)
            dismiss()
          }
        } label: {
          Text(CommonWords().done)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.Info)
        }
      }
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .zIndex(1)
      ZStack {
        scaledImageView()
          .frame(width: UIScreen.width, height: UIScreen.width)
        cropImageView()
          .frame(width: UIScreen.width, height: UIScreen.width)
      }
      .frame(width: UIScreen.width, height: UIScreen.width)
      .clipped()
      .zIndex(0)
      HStack(spacing: 8) {
        Button {
          photoCollection.fetchAlbumList()
          showAlbumList = true
        } label: {
          HStack {
            Text(albumName)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.labelColorPrimary)
            Image(systemName: "chevron.down")
              .foregroundColor(.labelColorPrimary)
          }
          .frame(height: 54)
        }
        Spacer()
      }
      .padding(.horizontal, 16)
      ScrollView {
        LazyVGrid(columns: columns, spacing: 1) {
          ForEach(photoCollection.photoAssets) { asset in
            Button {
              photoCollection
                .fetchPhotoByLocalIdentifier(localIdentifier: asset.phAsset?.localIdentifier ?? "") { photo in
                  selectedImage = photo?.photo
                }
            } label: {
              photoItemView(asset: asset)
            }
          }
        }
      }
      .ignoresSafeArea()
    }
    .background(Color.backgroundDefault)
    .task {
      let authorized = await PhotoLibrary.checkAuthorization()
      guard authorized else {
        return
      }
      Task {
        do {
          try await photoCollection.load()
          photoCollection
            .fetchPhotoByLocalIdentifier(
              localIdentifier: photoCollection.photoAssets.first?.phAsset?
                .localIdentifier ?? "")
          { photo in
            selectedImage = photo?.photo
          }
        } catch {
          WhistleLogger.logger.error("Error: \(error)")
        }
      }
    }
    .fullScreenCover(isPresented: $showAlbumList) {
      AlbumListView(albumName: $albumName, showAlbumList: $showAlbumList)
        .environmentObject(photoCollection)
    }
  }
}

extension ProfileImagePickerView {
  private func photoItemView(asset: PhotoAsset) -> some View {
    PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: imageSize)
      .frame(width: Self.itemSize.width, height: Self.itemSize.height)
      .clipped()
      .onAppear {
        Task {
          await photoCollection.cache.startCaching(for: [asset], targetSize: imageSize)
        }
      }
      .onDisappear {
        Task {
          await photoCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
        }
      }
  }

  @ViewBuilder
  func scaledImageView() -> some View {
    let cropSize = crop.size()
    GeometryReader {
      let size = $0.size
      if let selectedImage {
        Image(uiImage: selectedImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(size)
      }
    }
    .offset(offset)
    .scaleEffect(scale)
    .frame(cropSize)
    .overlay {
      Color.Dim_Default
    }
  }

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

// MARK: - Crop

enum Crop: Equatable {
  case circle
  case square
  case custom(CGSize)

  func name() -> String {
    switch self {
    case .circle:
      "Circle"
    case .square:
      "Square"
    case .custom(let cGSize):
      "Custom \(Int(cGSize.width))x\(Int(cGSize.height))"
    }
  }

  func size() -> CGSize {
    switch self {
    case .circle:
      .init(width: UIScreen.width, height: UIScreen.width)
    case .square:
      .init(width: UIScreen.width, height: UIScreen.width)
    case .custom(let cGSzie):
      cGSzie
    }
  }
}

// MARK: - PhotoItemView

struct PhotoItemView: View {
  var asset: PhotoAsset
  var cache: CachedImageManager?
  var imageSize: CGSize
  @State private var image: Image?
  @State private var imageRequestID: PHImageRequestID?

  var body: some View {
    Group {
      if let image {
        image
          .resizable()
          .scaledToFill()
      } else {
        ProgressView()
          .scaleEffect(0.5)
      }
    }
    .task {
      guard image == nil, let cache else { return }
      imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
        Task {
          if let result {
            image = result.image
          }
        }
      }
    }
  }
}

// MARK: - AlbumListView

struct AlbumListView: View {
  @EnvironmentObject var photoCollection: PhotoCollection
  @Binding var albumName: String
  @Binding var showAlbumList: Bool
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button {
          showAlbumList = false
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 20))
            .contentShape(Rectangle())
            .foregroundColor(.labelColorPrimary)
        }
        Spacer()
        Text(CommonWords().album)
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.labelColorPrimary)
        Spacer()
        EmptyView()
      }
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      Divider().frame(width: UIScreen.width)
      List(photoCollection.albums, id: \.name) { album in
        Button {
          Task {
            albumName = album.name
            if album.isSmartAlbum {
              await photoCollection.fetchAssetsInSmartAlbum(albumName: album.name)
            } else {
              await photoCollection.fetchAssetsInAlbum(albumName: album.name)
            }
          }
          showAlbumList = false
        } label: {
          HStack(spacing: 16) {
            Image(uiImage: album.thumbnail ?? UIImage())
              .resizable()
              .frame(width: 64, height: 64)
              .cornerRadius(8)
              .overlay {
                RoundedRectangle(cornerRadius: 8)
                  .stroke(lineWidth: 1)
                  .foregroundColor(.borderDefault)
                  .frame(width: 64, height: 64)
              }
            VStack(spacing: 0) {
              Text("\(album.name)")
                .fontSystem(fontDesignSystem: .subtitle1)
                .foregroundColor(.labelColorPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
              Text("\(album.count)")
                .fontSystem(fontDesignSystem: .body1)
                .foregroundColor(.labelColorSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .listRowSeparator(.hidden)
          .frame(height: 80)
        }
      }
      .listStyle(.plain)
    }
    .background(Color.backgroundDefault)
    .padding(.horizontal, 16)
  }
}
