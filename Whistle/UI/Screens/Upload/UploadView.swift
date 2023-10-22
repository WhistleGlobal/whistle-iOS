//
//  UploadView.swift
//  Whistle
//
//  Created by 박상원 on 10/9/23.
//

import BottomSheet
import Combine
import SwiftUI

// MARK: - UploadView

struct UploadView: View {
  let video: EditableVideo
  @Environment(\.dismiss) private var dismiss
  @StateObject var tagsViewModel = TagsViewModel()
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var exporterVM: ExporterViewModel
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var musicVM: MusicViewModel
  @FocusState private var isFocused: Bool
  @State var content = ""
  @State var sheetPosition: BottomSheetPosition = .hidden
  @State var showTagCountMax = false
  @State var showTagTextCountMax = false
  @State private var inputText = "\u{200B}"
  @Binding var isInitial: Bool
  let videoScale: CGFloat = 16 / 9
  let videoWidth: CGFloat = 203
  let textLimit = 40

  init(
    video: EditableVideo,
    editorVM: EditorViewModel,
    videoPlayer: VideoPlayerManager,
    musicVM: MusicViewModel,
    isInitial: Binding<Bool>)
  {
    self.video = video
    _exporterVM = StateObject(wrappedValue: ExporterViewModel(video: video))
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
      CustomNavigationBarViewController(title: "새 게시물", nextText: "게시", backgroundColor: .white) {
        isInitial = false
        dismiss()
      } nextButtonAction: {
        Task {
          UploadProgressViewModel.shared.uploadStarted()
          NavigationModel.shared.navigate.toggle()
        }
        Task {
          let thumbnail = editorVM
            .returnThumbnail(Int(
              (editorVM.currentVideo?.rangeDuration.lowerBound)! / (editorVM.currentVideo?.originalDuration)! *
                21))
          UploadProgressViewModel.shared.thumbnail = Image(uiImage: thumbnail)
          await exporterVM.action(.save, start: (editorVM.currentVideo?.rangeDuration.lowerBound)!)
          let video = exporterVM.videoData
          apiViewModel.uploadPost(
            video: video,
            thumbnail: thumbnail.jpegData(compressionQuality: 0.5)!,
            caption: content,
            musicID: musicVM.musicInfo?.musicID ?? 0,
            videoLength: editorVM.currentVideo!.totalDuration,
            hashtags: tagsViewModel.getTags())
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
          Image(
            uiImage: editorVM
              .returnThumbnail(Int((
                (editorVM.currentVideo?.rangeDuration.lowerBound)! /
                  (editorVM.currentVideo?.originalDuration)! * 21).rounded())))
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
            .cornerRadius(12)
            .background(Color.black.clipShape(RoundedRectangle(cornerRadius: 12)))
          TextField(
            "",
            text: $content,
            prompt: Text("내용을 입력해 주세요. (40자 내)")
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
              Text("\(content.count)자 / 40자")
                .padding()
                .foregroundStyle(Color.Disable_Placeholder_Light)
                .fontSystem(fontDesignSystem: .body2_KO)
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
    .bottomSheet(bottomSheetPosition: $sheetPosition, switchablePositions: [.hidden, .dynamicTop], headerContent: {
      ZStack(alignment: .center) {
        HStack {
          Text("취소")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundStyle(Color.black)
            .contentShape(Rectangle())
            .onTapGesture {
              sheetPosition = .hidden
            }
          Spacer()
          Text("완료")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundStyle(Color.Info)
            .contentShape(Rectangle())
            .onTapGesture {
//              log("inputText: ->\(inputText)<-")
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
          .fontSystem(fontDesignSystem: .subtitle1_KO)
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
        if showTagCountMax {
          ToastMessage(text: "해시태그는 최대 5개까지만 가능합니다", toastPadding: 32, showToast: $showTagCountMax)
        }
        if showTagTextCountMax {
          ToastMessage(text: "해시태그는 최대 16글자까지 가능합니다", toastPadding: 32, showToast: $showTagTextCountMax)
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
//    .ignoresSafeArea(.keyboard)
    .scrollDismissesKeyboard(.interactively)
  }

  func limitText(_ upper: Int) {
    if content.count > upper {
      content = String(content.prefix(upper))
    }
  }
}

//
// #Preview {
//  UploadView(
//    editorVM: EditorViewModel(),
//    videoPlayer: VideoPlayerManager(),
//    musicVM: MusicViewModel(),
//    isInitial: .constant(false))
// }
