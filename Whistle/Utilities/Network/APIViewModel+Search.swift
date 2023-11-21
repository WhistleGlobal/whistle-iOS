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
      .validate(statusCode: 200...300)
      .responseDecodable(of: [SearchedUser].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedUser = data
        case .failure(let error):
          WhistleLogger.logger.error("\(error)")
          break
        }
      }
  }

  func requestSearchedTag(queryString: String) {
    AF.request(
      "\(domainURL)/search/hashtag?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200...300)
      .responseDecodable(of: [SearchedTag].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedTag = data
        case .failure(let error):
          WhistleLogger.logger.error("requestSearchedTag(queryString: String) \(error)")
          break
        }
      }
  }

  func requestSearchedContent(queryString: String) {
    AF.request(
      "\(domainURL)/search/content?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200...300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedContent = data
        case .failure(let error):
          WhistleLogger.logger.error("requestSearchedTag(queryString: String) \(error)")
          break
        }
      }
  }

  func requestTagSearchedRecentContent(queryString: String, completion: @escaping ([MainContent]) -> Void) {
    AF.request(
      "\(domainURL)/search/hashtag-content?query=\(queryString)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200...300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.tagSearchedRecentContent = data
          completion(self.tagSearchedRecentContent)
        case .failure(let error):
          WhistleLogger.logger.error("requestTagSearchedContent(queryString: String) \(error)")
          break
        }
      }
  }
}
