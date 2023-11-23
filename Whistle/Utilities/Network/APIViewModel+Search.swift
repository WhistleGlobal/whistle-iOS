//
//  APIViewModel+Search.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import Alamofire
import Foundation
import SwiftyJSON

extension APIViewModel: SearchProtocol {
  func requestSearchedUser(queryString: String) {
    AF.request(
      "\(domainURL)/search/user?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [SearchedUser].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedUser = data
          SearchProgressViewModel.shared.searchUserFound()
        case .failure(let error):
          SearchProgressViewModel.shared.searchUserNotFound()
          WhistleLogger.logger.error("\(error)")
        }
      }
  }

  func requestSearchedTag(queryString: String) {
    AF.request(
      "\(domainURL)/search/hashtag?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [SearchedTag].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedTag = data
          SearchProgressViewModel.shared.searchTagFound()
        case .failure(let error):
          SearchProgressViewModel.shared.searchTagNotFound()
          WhistleLogger.logger.error("requestSearchedTag(queryString: String) \(error)")
        }
      }
  }

  func requestSearchedContent(queryString: String) {
    AF.request(
      "\(domainURL)/search/content?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedContent = data
          SearchProgressViewModel.shared.searchContentFound()
        case .failure(let error):
          SearchProgressViewModel.shared.searchContentNotFound()
          WhistleLogger.logger.error("requestSearchedTag(queryString: String) \(error)")
        }
      }
  }

  func requestTagSearchedRecentContent(queryString: String, completion: @escaping ([MainContent]) -> Void) {
    SearchProgressViewModel.shared.searchTagContent()
    AF.request(
      "\(domainURL)/search/hashtag-content?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.tagSearchedRecentContent = data
          completion(self.tagSearchedRecentContent)
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SearchProgressViewModel.shared.searchTagContentFound()
          }
        case .failure(let error):
          WhistleLogger.logger.error("requestTagSearchedContent(queryString: String) \(error)")
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SearchProgressViewModel.shared.searchTagContentNotFound()
          }
        }
      }
  }
}
