//
//  TagsDataModel.swift
//  Whistle
//
//  Created by 박상원 on 10/10/23.
//

import Foundation

// MARK: - TagRole

enum TagRole {
  case editable, noneditable, textfield
}

// MARK: - TagsDataModel

struct TagsDataModel: Identifiable {
  let id = UUID()
  var role: TagRole = .editable
  var titleKey: String
}
