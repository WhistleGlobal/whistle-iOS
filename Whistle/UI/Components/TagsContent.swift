//
//  TagsContent.swift
//  Whistle
//
//  Created by 박상원 on 10/10/23.
//

import BottomSheet
import Combine
import SwiftUI

// MARK: - TagsContent

struct TagsContent<Overlay>: View where Overlay: View {
  @StateObject private var toastViewModel = ToastViewModel.shared
  @ObservedObject var viewModel = TagsViewModel()
  @FocusState private var isFocused: Bool

  @Binding var inputText: String
  @Binding var sheetPosition: BottomSheetPosition
  @Binding var showTagCountMax: Bool
  @Binding var showTagTextCountMax: Bool

  private let zwsp = "\u{200B}"
  let overlayContent: () -> Overlay

  var body: some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    return GeometryReader { geo in
      if sheetPosition != .hidden {
        // 해시태그 입력 bottomsheet에서 보여줄 뷰
        VStack(alignment: .leading, spacing: 0) {
          ZStack(alignment: .topLeading) {
            ForEach(viewModel.editingTags) { tagsData in
              Tags(titleKey: tagsData.titleKey, editable: tagsData.role == .editable ? true : false) {
                viewModel.removeTag(id: tagsData.id)
              }
              .foregroundColor(Color.Gray60_Light)
              .background(Capsule().fill(Color.Gray20_Light))
              .opacity(tagsData.role == .textfield ? 0 : 1)
              .padding(.all, 4)
              .alignmentGuide(.leading) { dimension in
                if abs(width - dimension.width) > geo.size.width - 28 {
                  width = 0
                  height -= dimension.height
                }
                let result = width
                if
                  tagsData.id == (viewModel.getEditableAndTextfieldLastID())
                {
                  width = 0
                } else {
                  width -= dimension.width
                }
                return result
              }
              .alignmentGuide(.top) { _ in
                let result = height
                if
                  tagsData.id == (viewModel.getEditableAndTextfieldLastID())
                {
                  height = 0
                }
                return result
              }
              .overlay(alignment: .leading) {
                if tagsData.id == viewModel.getEditableAndTextfieldLastID(), viewModel.editableTagCount < 5 {
                  tagTextField()
                    .onDisappear {
                      if sheetPosition != .hidden {
                        toastViewModel.toastInit(message: ToastMessages().tagLimit, padding: 32)
                      }
                    }
                }
              }
            }
          }
          .padding(.top, 16)
          .padding(.horizontal, 12)
        }
      } else {
        // Description 뷰에서 보여줄 뷰
        ZStack(alignment: .topLeading) {
          ForEach(viewModel.displayedTags) { tagsData in
            Tags(titleKey: tagsData.titleKey, editable: tagsData.role == .editable ? true : false) {
              viewModel.removeTag(id: tagsData.id)
            }
            .onTapGesture {
              if tagsData.role == .noneditable {
                sheetPosition = .dynamicTop
              }
            }
            .foregroundColor(tagsData.role == .noneditable ? Color.Disable_Placeholder_Dark : Color.Gray60_Light)
            .background(Capsule().fill(Color.Gray20_Light))
            .opacity(tagsData.role == .noneditable && viewModel.editableTagCount >= 5 ? 0 : 1)
            .padding(.all, 4)
            .alignmentGuide(.leading) { dimension in
              if abs(width - dimension.width) > geo.size.width - 28 {
                width = 0
                height -= dimension.height
              }
              let result = width
              if
                tagsData.id == viewModel.getTagDataLastID()
              {
                width = 0
              } else {
                width -= dimension.width
              }
              return result
            }
            .alignmentGuide(.top) { _ in
              let result = height
              if
                tagsData.id == viewModel.getTagDataLastID()
              {
                height = 0
              }
              return result
            }
          }
        }
        .padding(.horizontal, 12)
      }
    }
  }

  @ViewBuilder
  func tagTextField() -> some View {
    TextField(" ", text: $inputText)
      .tint(.Info)
      .autocorrectionDisabled()
      .focused($isFocused)
      .fontSystem(fontDesignSystem: .body1)
      .foregroundColor(Color.Gray60_Light)
      .lineLimit(1)
      .truncationMode(.tail)
      .padding(.leading, 10)
      .contentShape(Rectangle())
      .overlay(alignment: .leading) {
        Text("#")
          .fontSystem(fontDesignSystem: .body1)
          .foregroundColor(Color.Gray60_Light)
      }
      .padding(.vertical, 4)
      .padding(.horizontal, 16)
      .frame(maxWidth: UIScreen.getWidth(361), alignment: .leading)
      .fixedSize()
      .onReceive(Just($inputText)) { _ in
        limitText(15)
      }
      .background(
        Capsule()
          .fill(Color.Gray20_Light))
      .padding(.leading, 4)
      .onSubmit(of: .text) {
        // 엔터가 눌렸을 때
        if inputText != zwsp {
          viewModel.addTag(chipText: inputText)
          inputText = zwsp
        }
      }
      .onAppear {
        isFocused = true
      }
      .onChange(of: inputText) { _ in
        // 입력 도중 공백이 들어왔을 때
        if inputText.hasSuffix(" ") {
          viewModel.addTag(chipText: String(inputText[..<inputText.index(before: inputText.endIndex)]))
          inputText = zwsp
          isFocused = true
        }
        // 백스페이스 누를때
        else if !viewModel.dataObject.isEmpty, inputText.isEmpty {
          if viewModel.dataObject.count > 2 {
            let last = viewModel.dataObject.remove(at: max(0, viewModel.dataObject.count - 3)).titleKey
            inputText = last
          }
        }
      }
  }
}

extension TagsContent {
  // Function to keep text length in limits
  func limitText(_ upper: Int) {
    if inputText.filter({ $0 != " " }).count > upper {
      toastViewModel.toastInit(message: ToastMessages().tagLengthLimit, padding: 32)
      inputText = String(inputText.prefix(upper))
    }
  }
}
