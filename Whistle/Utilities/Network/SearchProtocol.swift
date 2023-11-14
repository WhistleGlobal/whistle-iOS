//
//  SearchProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import Foundation

protocol SearchProtocol {

  func requestSearchedUser(queryString: String)
  func requestSearchedTag(queryString: String)
}
