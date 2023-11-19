//
//  DescriptionAndTagEditorView.swift
//  Whistle
//
//  Created by 박상원 on 10/9/23.
//

import BottomSheet
import Combine
import SwiftUI

// MARK: - DescriptionAndTagEditorView

struct DescriptionAndTagEditorView: View {
  @AppStorage("isAccess") var isAccess = false
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) var scenePhase
  @StateObject var tagsViewModel = TagsViewModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var exporterVM: VideoExporterViewModel
  @StateObject var guestUploadModel = GuestUploadModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @ObservedObject var editorVM: VideoEditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var musicVM: MusicViewModel
  @FocusState private var isFocused: Bool

  @State var content = ""
  @State var onProgress = false
  @State var sheetPosition: BottomSheetPosition = .hidden
  @State var showTagCountMax = false
  @State var showTagTextCountMax = false
  @State private var inputText = "\u{200B}"
  @Binding var isInitial: Bool

  let video: EditableVideo
  var thumbnail: Image?
  let videoScale: CGFloat = 16 / 9
  let videoWidth: CGFloat = 203
  let textLimit = 100

  init(
    video: EditableVideo,
    thumbnail: Image?,
    editorVM: VideoEditorViewModel,
    videoPlayer: VideoPlayerManager,
    musicVM: MusicViewModel,
    isInitial: Binding<Bool>)
  {
    self.video = video
    self.thumbnail = thumbnail
    _exporterVM = StateObject(wrappedValue: VideoExporterViewModel(video: video, musicVolume: musicVM.musicVolume))
    self.editorVM = editorVM
    self.videoPlayer = videoPlayer
    self.musicVM = musicVM
    _isInitial = isInitial
  }

  var body: some View {
    ZStack(alignment: .top) {
      Color.white
        .ignoresSafeArea()
        .onTapGesture {
          isFocused = false
        }
      CustomNavigationBarViewController(title: "새 게시물", nextText: "게시", isPostNavBar: true, backgroundColor: .white) {
        isInitial = false
        dismiss()
        toastViewModel.onFullScreenCover = false
      } nextButtonAction: {
        onProgress = true
        toastViewModel.onFullScreenCover = false
        Task {
          if guestUploadModel.istempAccess {
            isAccess = true
            tabbarModel.showTabbar()
          }
          UploadProgressViewModel.shared.uploadStarted()
        }
        Task {
          if let video = editorVM.currentVideo {
            UploadProgressViewModel.shared.thumbnail = video.getThumbnail(start: video.rangeDuration.lowerBound)
            NavigationModel.shared.navigate.toggle()
            await exporterVM.action(.save, start: video.rangeDuration.lowerBound)
            if let url = exporterVM.renderedVideoURL {
              VideoCompression
                .compressh264Video(from: url, cache: .forceDelete, preferred: .quantity(ratio: 1.0)) { item, error in
                  if let error {
                    apiViewModel.uploadContent(
                      video: exporterVM.videoData,
                      thumbnail: exporterVM.thumbnailData,
                      caption: content,
                      musicID: musicVM.musicInfo?.musicID ?? 0,
                      videoLength: video.totalDuration,
                      aspectRatio: exporterVM.aspectRatio,
                      hashtags: tagsViewModel.getTags())
                  } else {
                    if let item {
                      var data = Data()
                      if let videoData = try? Data(contentsOf: item) {
                        data = videoData
                      }
                      apiViewModel.uploadContent(
                        video: data,
                        thumbnail: exporterVM.thumbnailData,
                        caption: content,
                        musicID: musicVM.musicInfo?.musicID ?? 0,
                        videoLength: video.totalDuration,
                        aspectRatio: exporterVM.aspectRatio,
                        hashtags: tagsViewModel.getTags())
                    }
                  }
                }
            }
            if let renderedVideoURL = exporterVM.renderedVideoURL {
              FileManager.default.removefileExists(for: renderedVideoURL)
            }
            exporterVM.renderedVideoURL = nil
          }
        }
      }
      .frame(height: UIScreen.getHeight(44))
      .overlay(alignment: .bottom) {
        Rectangle()
          .frame(height: 1)
          .foregroundStyle(Color.Border_Default_Dark)
      }
      .background(Rectangle().fill(.white).ignoresSafeArea())
      .ignoresSafeArea(.keyboard)
      .zIndex(1000)

      ScrollView {
        VStack(spacing: 16) {
          if let thumbnail {
            thumbnail
              .resizable()
              .scaledToFit()
              .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
              .cornerRadius(12)
              .background {
                Color.black.clipShape(RoundedRectangle(cornerRadius: 12))
              }
              .overlay {
                if editorVM.currentVideo?.thumbHQImages.isEmpty ?? true {
                  ProgressView()
                }
              }
          } else {
            Image(
              uiImage: editorVM
                .returnThumbnail(Int((
                  (editorVM.currentVideo?.rangeDuration.lowerBound)! /
                    (editorVM.currentVideo?.originalDuration)! * 21).rounded())))
              .resizable()
              .scaledToFit()
              .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
              .cornerRadius(12)
              .background {
                Color.black.clipShape(RoundedRectangle(cornerRadius: 12))
              }
              .overlay {
                if editorVM.currentVideo?.thumbHQImages.isEmpty ?? true {
                  ProgressView()
                }
              }
          }
          TextField(
            "",
            text: $content,
            prompt: Text("내용을 입력해 주세요. (\(textLimit)자 내)")
              .foregroundColor(Color.Disable_Placeholder_Light)
              .font(.custom("AppleSDGothicNeo-Regular", size: 16)),
            axis: .vertical)
            .foregroundStyle(Color.black)
            .onReceive(Just(content)) { _ in
              limitText(textLimit)
            }
            .frame(height: UIScreen.getHeight(160), alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
              isFocused = true
            }
            .padding(UIScreen.getWidth(16))
            .focused($isFocused)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.Border_Default_Dark))
            .overlay(alignment: .bottomTrailing) {
              Text("\(content.count)자 / \(textLimit)자")
                .padding()
                .foregroundStyle(Color.Disable_Placeholder_Light)
                .fontSystem(fontDesignSystem: .body2)
            }
            .padding(.horizontal, UIScreen.getWidth(16))

          ZStack(alignment: .topLeading) {
            TagsContent(
              viewModel: tagsViewModel,
              inputText: $inputText,
              sheetPosition: $sheetPosition,
              showTagCountMax: $showTagCountMax,
              showTagTextCountMax: $showTagTextCountMax)
            {
              EmptyView()
            }
          }
          .padding(.bottom, CGFloat(tagsViewModel.getEditableCount()) * 0.5 * 100)
        }
        .padding(.top, UIScreen.getHeight(54))
      }
      .onTapGesture {
        isFocused = false
      }
      .scrollIndicators(.visible)
      .offset(y: isFocused ? UIScreen.getHeight(-300) : 0)
      .animation(.easeInOut)
      .ignoresSafeArea(edges: .bottom)
    }
    .onAppear {
      toastViewModel.onFullScreenCover = true
    }
    .bottomSheet(bottomSheetPosition: $sheetPosition, switchablePositions: [.hidden, .dynamicTop], headerContent: {
      ZStack(alignment: .center) {
        HStack {
          Text(CommonWords().cancel)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundStyle(Color.black)
            .contentShape(Rectangle())
            .onTapGesture {
              sheetPosition = .hidden
            }
          Spacer()
          Text(CommonWords().done)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundStyle(Color.Info)
            .contentShape(Rectangle())
            .onTapGesture {
              if !inputText.isEmpty, inputText != "\u{200B}" {
                tagsViewModel.dataObject.insert(
                  TagsDataModel(titleKey: inputText),
                  at: max(0, tagsViewModel.dataObject.count - 2))
                inputText = "\u{200B}"
              }
              sheetPosition = .hidden
            }
        }
        Text("해시태그")
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundStyle(Color.black)
      }
      .padding(.top, 10)
      .padding(.horizontal, 16)
      .padding(.bottom, 14)
      .overlay(alignment: .bottom) {
        Rectangle().fill(Color.Border_Default_Dark).frame(height: 1)
      }
    }, mainContent: {
      ZStack(alignment: .topLeading) {
        TagsContent(
          viewModel: tagsViewModel,
          inputText: $inputText,
          sheetPosition: $sheetPosition,
          showTagCountMax: $showTagCountMax,
          showTagTextCountMax: $showTagTextCountMax)
        {
          Text("")
        }
      }
      .overlay {
        if toastViewModel.onFullScreenCover {
          ToastMessageView()
        }
      }
    })
    .enableTapToDismiss()
    .enableSwipeToDismiss()
    .enableBackgroundBlur(true)
    .backgroundBlurMaterial(.systemDark)
    .customBackground(
      Rectangle()
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .foregroundStyle(Color.white))
    .toolbar(.hidden)
    .scrollDismissesKeyboard(.interactively)
    .onChange(of: scenePhase) { newValue in
      if newValue == .background {
        if guestUploadModel.istempAccess {
          isAccess = true
          tabbarModel.showTabbar()
        }
      }
    }
  }

  func limitText(_ upper: Int) {
    if content.count > upper {
      content = String(content.prefix(upper))
    }
  }
}
