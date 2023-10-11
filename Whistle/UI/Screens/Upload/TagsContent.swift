//
//  TagContent.swift
//  Whistle
//
//  Created by 박상원 on 10/10/23.
//

import BottomSheet
import SwiftUI

struct TagsContent<Overlay>: View where Overlay: View {
  private let zwsp = "\u{200B}"
  @ObservedObject var viewModel = TagsViewModel()
  @FocusState private var isFocused: Bool
  @State private var inputText = "\u{200B}"
  @Binding var sheetPosition: BottomSheetPosition
  let overlayContent: () -> Overlay

  var body: some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    return GeometryReader { geo in
      if sheetPosition != .hidden {
        VStack(alignment: .leading, spacing: 0) {
          ScrollView {
            ZStack(alignment: .topLeading) {
              ForEach(viewModel.editableDataObject()) { tagsData in
                Tags(titleKey: tagsData.titleKey, editable: tagsData.role == .editable ? true : false) {
                  if viewModel.dataObject.count > 1 {
                    withAnimation {
                      viewModel.dataObject.removeAll(where: { $0.id == tagsData.id })
                    }
                  }
                }
                .foregroundColor(Color.Gray60_Light)
                .background(Capsule().fill(Color.Gray20_Light))
                .opacity(tagsData.role == .textfield ? 0 : 1)
                .padding(.all, 4)
                .alignmentGuide(.leading) { dimension in
                  if abs(width - dimension.width) > geo.size.width {
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
                  if tagsData.id == viewModel.getEditableAndTextfieldLastID(), viewModel.getEditableCount() < 5 {
                    tagTextField()
                  }
                }
              }
            }
          }
          .frame(height: UIScreen.getHeight(104))
          .padding(.top, 16)
          .padding(.horizontal, 12)
          .scrollIndicators(.never)
          Rectangle().fill(Color.Border_Default_Dark).frame(height: 1)
        }
      } else {
        ZStack(alignment: .topLeading) {
          ForEach(viewModel.tagDataObject()) { tagsData in
            Tags(titleKey: tagsData.titleKey, editable: tagsData.role == .editable ? true : false) {
              if viewModel.dataObject.count > 1 {
                withAnimation {
                  viewModel.dataObject.removeAll(where: { $0.id == tagsData.id })
                }
              }
            }
            .onTapGesture {
              if tagsData.role == .noneditable {
                sheetPosition = .dynamicTop
              }
            }
            .foregroundColor(tagsData.role == .noneditable ? Color.Disable_Placeholder_Dark : Color.Gray60_Light)
            .background(Capsule().fill(Color.Gray20_Light))
            .opacity(tagsData.role == .noneditable && viewModel.getEditableCount() >= 5 ? 0 : 1)
            .padding(.all, 4)
            .alignmentGuide(.leading) { dimension in
              if abs(width - dimension.width) > geo.size.width {
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
      .autocorrectionDisabled()
      .focused($isFocused)
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(Color.Gray60_Light)
      .lineLimit(1)
      .truncationMode(.tail)
      .padding(.leading, 8)
      .overlay(alignment: .leading) {
        Text("#")
          .fontSystem(fontDesignSystem: .body1_KO)
          .foregroundColor(Color.Gray60_Light)
      }
      .padding(.vertical, 4)
      .padding(.horizontal, 16)
      .frame(maxWidth: UIScreen.getWidth(361))
      .fixedSize()
      .background(
        Capsule()
          .fill(Color.Gray20_Light))
      .padding(.leading, 4)
      .onSubmit(of: .text) {
        if inputText != zwsp {
          viewModel.dataObject.insert(
            TagsDataModel(titleKey: inputText),
            at: max(0, viewModel.dataObject.count - 2))
          inputText = zwsp
        }
        isFocused = false
      }
      .onAppear {
        isFocused = true
      }
      .onChange(of: inputText) { value in
        viewModel.dataObject[viewModel.dataObject.count - 2].titleKey = value
        if inputText.hasSuffix(" ") {
          viewModel.dataObject.insert(
            TagsDataModel(titleKey: String(inputText[..<inputText.index(before: inputText.endIndex)])),
            at: max(0, viewModel.dataObject.count - 2))
          inputText = zwsp
          isFocused = true
        } else if !viewModel.dataObject.isEmpty, inputText.isEmpty {
          if viewModel.dataObject.count > 2 {
            let last = viewModel.dataObject.remove(at: max(0, viewModel.dataObject.count - 3)).titleKey
            inputText = last
          }
        }
      }
  }
}

// #Preview {
//  TagsContent(viewModel: TagsViewModel(), overlayContent: { Text("") })
// }