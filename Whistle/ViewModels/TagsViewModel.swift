//
//  TagsViewModel.swift
//  Whistle
//
//  Created by 박상원 on 10/10/23.
//

import SwiftUI

class TagsViewModel: ObservableObject {
  @Published var dataObject: [TagsDataModel] = [
    TagsDataModel(role: .textfield, titleKey: ""),
    TagsDataModel(role: .noneditable, titleKey: "해시태그 추가 (최대 5개)"),
  ]

  @Published var displayedDataObject: [TagsDataModel] = [
    TagsDataModel(role: .textfield, titleKey: ""),
    TagsDataModel(role: .noneditable, titleKey: "해시태그 추가 (최대 5개)"),
  ]

  var displayedTags: [TagsDataModel] {
    displayedDataObject.filter { $0.role == .editable || $0.role == .noneditable }
  }

  var editingTags: [TagsDataModel] {
    dataObject.filter { $0.role == .editable || $0.role == .textfield }
  }

  var editableTagCount: Int {
    dataObject.filter { $0.role == .editable }.count
  }

  func addTag(chipText: String) {
    dataObject.insert(TagsDataModel(titleKey: chipText), at: max(0, dataObject.count - 2))
  }

  func removeTag(id: UUID) {
    if dataObject.count > 1 {
      withAnimation {
        dataObject.removeAll(where: { $0.id == id })
        displayedDataObject.removeAll(where: { $0.id == id })
      }
    }
  }

  func getEditableAndTextfieldLastID() -> UUID {
    editingTags.last!.id
  }

  func getTagDataLastID() -> UUID {
    displayedTags.last!.id
  }

  func getTags() -> [String] {
    let inputArray = editingTags.filter { $0.role == .editable }.map { $0.titleKey }
    WhistleLogger.logger.debug("inputArr: \(inputArray)")
    // 공백을 제거한 결과를 저장할 배열
    var resultArray: [String] = []

    for inputString in inputArray {
      // 문자열의 앞 뒤 공백을 제거하고, 빈 문자열이 아닌 경우에만 결과 배열에 추가
      let trimmedString = inputString.trimmingCharacters(in: .whitespaces)
      if !trimmedString.isEmpty {
        resultArray.append(trimmedString)
      }
    }
    return resultArray
  }
}
