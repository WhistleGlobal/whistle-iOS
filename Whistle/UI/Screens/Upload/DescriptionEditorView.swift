//
//  DescriptionEditorView.swift
//  Whistle
//
//  Created by 박상원 on 10/9/23.
//

import BottomSheet
import Combine
import Mixpanel
import SwiftUI

// MARK: - DescriptionEditorView

struct DescriptionEditorView: View {
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
  @FocusState private var isURLFocused: Bool

  @State var caption = ""
  @State var sourceURL = ""
  @State var onProgress = false
  @State var sheetPosition: BottomSheetPosition = .hidden
  @State var showTagCountMax = false
  @State var showTagTextCountMax = false
  @State private var inputText = "\u{200B}"
  @Binding var isInitial: Bool

  let uploadMethod: UploadMethod
  let video: EditableVideo
  var thumbnail: Image?
  let videoScale: CGFloat = 16 / 9
  let videoWidth: CGFloat = 203
  let textLimit = 100

  init(
    uploadMethod: UploadMethod = .camera,
    video: EditableVideo,
    thumbnail: Image?,
    editorVM: VideoEditorViewModel,
    videoPlayer: VideoPlayerManager,
    musicVM: MusicViewModel,
    isInitial: Binding<Bool>)
  {
    self.uploadMethod = uploadMethod
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
          isURLFocused = false
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
          UploadProgress.shared.uploadStarted()
        }
        Task {
          if let video = editorVM.currentVideo {
            UploadProgress.shared.thumbnail = video.getThumbnail(start: video.rangeDuration.lowerBound)
            NavigationModel.shared.navigate.toggle()
            await exporterVM.action(.save, start: video.rangeDuration.lowerBound)
            // 출처 url의 형식 점검. 반드시 http가 포함되어야 정상 URL로 간주됨
            sourceURL = sourceURL.replacingOccurrences(of: " ", with: "")
            if !sourceURL.isEmpty, !sourceURL.hasPrefix("http") {
              sourceURL = "https://" + sourceURL
            }
            if let url = exporterVM.renderedVideoURL {
              VideoCompression
                .compressh264Video(from: url, cache: .forceDelete, preferred: .quantity(ratio: 1.0)) { item, error in
                  if error != nil {
                    apiViewModel.uploadContent(
                      video: exporterVM.videoData,
                      thumbnail: exporterVM.thumbnailData,
                      caption: caption,
                      sourceURL: sourceURL,
                      musicID: musicVM.musicInfo?.musicID ?? 0,
                      videoLength: video.totalDuration,
                      aspectRatio: exporterVM.aspectRatio,
                      hashtags: tagsViewModel.getTags(),
                      uploadMethod: uploadMethod)
                  } else {
                    if let item {
                      var data = Data()
                      if let videoData = try? Data(contentsOf: item) {
                        data = videoData
                      }
                      apiViewModel.uploadContent(
                        video: data,
                        thumbnail: exporterVM.thumbnailData,
                        caption: caption,
                        sourceURL: sourceURL,
                        musicID: musicVM.musicInfo?.musicID ?? 0,
                        videoLength: video.totalDuration,
                        aspectRatio: exporterVM.aspectRatio,
                        hashtags: tagsViewModel.getTags(),
                        uploadMethod: uploadMethod)
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
          }
          TextField(
            "",
            text: $caption,
            prompt: Text("내용을 입력해 주세요. (\(textLimit)자 내)")
              .foregroundColor(Color.Disable_Placeholder_Light)
              .font(.system(size: 16)),
            axis: .vertical)
            .foregroundStyle(Color.black)
            .onReceive(Just(caption)) { _ in
              limitText(textLimit)
            }
            .frame(height: UIScreen.getHeight(150 - 32), alignment: .topLeading)
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
              Text("\(caption.count)자 / \(textLimit)자")
                .padding()
                .foregroundStyle(Color.Disable_Placeholder_Light)
                .fontSystem(fontDesignSystem: .body2)
            }
            .padding(.horizontal, UIScreen.getWidth(16))
            .tint(.Info)

          TextField(
            "",
            text: $sourceURL,
            prompt: Text("영상 출처 URL을 입력해주세요.")
              .foregroundColor(Color.Disable_Placeholder_Light)
              .font(.system(size: 16)))
            .foregroundStyle(Color.black)
            .lineLimit(1)
            .keyboardType(.URL)
            .textContentType(.URL)
            .frame(height: UIScreen.getHeight(50 - 26), alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
              isURLFocused = true
            }
            .padding(UIScreen.getWidth(13))
            .focused($isURLFocused)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.Border_Default_Dark))
            .padding(.horizontal, UIScreen.getWidth(16))
            .tint(.Info)

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
          .padding(.bottom, CGFloat(tagsViewModel.editableTagCount) * 0.5 * 100)
        }
        .padding(.top, UIScreen.getHeight(54))
      }
      .onTapGesture {
        isFocused = false
        isURLFocused = false
      }
      .scrollIndicators(.visible)
      .offset(y: isFocused ? UIScreen.getHeight(-300) : 0)
      .offset(y: isURLFocused ? UIScreen.getHeight(-300) : 0)
      .animation(.easeInOut)
      .ignoresSafeArea(edges: .bottom)
    }
    .onAppear {
      toastViewModel.onFullScreenCover = true
      Mixpanel.mainInstance().track(event: "write_content_description")
    }
    .bottomSheet(bottomSheetPosition: $sheetPosition, switchablePositions: [.hidden, .dynamicTop], headerContent: {
      ZStack(alignment: .center) {
        HStack {
          Text(CommonWords().cancel)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundStyle(Color.black)
            .contentShape(Rectangle())
            .onTapGesture {
              tagsViewModel.dataObject = tagsViewModel.displayedDataObject
              sheetPosition = .hidden
            }
          Spacer()
          Text(CommonWords().done)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundStyle(Color.Info)
            .contentShape(Rectangle())
            .onTapGesture {
              if !inputText.isEmpty, inputText != "\u{200B}" {
                tagsViewModel.addTag(chipText: inputText)
                inputText = "\u{200B}"
              }
              tagsViewModel.displayedDataObject = tagsViewModel.dataObject
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
    if caption.count > upper {
      caption = String(caption.prefix(upper))
    }
  }
}

// MARK: - UploadMethod

enum UploadMethod: String {
  case gallery
  case camera
}
