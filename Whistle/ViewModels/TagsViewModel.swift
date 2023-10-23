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

  func editableDataObject() -> [TagsDataModel] {
    dataObject.filter { $0.role == .editable || $0.role == .textfield }
  }

  func tagDataObject() -> [TagsDataModel] {
    dataObject.filter { $0.role == .editable || $0.role == .noneditable }
  }

  func appendChip(chipText: String) {
    dataObject.append(TagsDataModel(titleKey: chipText))
  }

  func getEditableCount() -> Int {
    dataObject.filter { $0.role == .editable }.count
  }

  func getEditableAndTextfieldLastID() -> UUID {
    editableDataObject().last!.id
  }

  func getTagDataLastID() -> UUID {
    tagDataObject().last!.id
  }

  func getTags() -> [String] {
    let inputArray = editableDataObject().map { $0.titleKey }
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
