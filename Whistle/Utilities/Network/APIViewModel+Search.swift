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
      "\(domainURL)/search/user?query=\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [SearchedUser].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedUser = data
          SearchProgressViewModel.shared.changeSearchUserState(to: .found)
        case .failure(let error):
          SearchProgressViewModel.shared.changeSearchUserState(to: .notFound)
          WhistleLogger.logger.error("\(error)")
        }
      }
  }

  func requestSearchedTag(queryString: String) {
    AF.request(
      "\(domainURL)/search/hashtag?query=\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [SearchedTag].self) { response in
        print(response.result)
        switch response.result {
        case .success(let data):
          self.searchedTag = data
          SearchProgressViewModel.shared.changeSearchTagState(to: .found)
        case .failure(let error):
          SearchProgressViewModel.shared.changeSearchTagState(to: .notFound)
          WhistleLogger.logger.error("requestSearchedTag(queryString: String) \(error)")
        }
      }
  }

  func requestSearchedContent(queryString: String) {
    AF.request(
      "\(domainURL)/search/content?query=\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.searchedContent = data
          SearchProgressViewModel.shared.changeSearchContentState(to: .found)
        case .failure(let error):
          SearchProgressViewModel.shared.changeSearchContentState(to: .notFound)
        }
      }
  }

  func requestTagSearchedRecentContent(queryString: String, completion: @escaping ([MainContent]) -> Void) {
    AF.request(
      "\(domainURL)/search/hashtag-content?query=\(queryString)"
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let data):
          self.tagSearchedRecentContent = data
          completion(self.tagSearchedRecentContent)
          SearchProgressViewModel.shared.changeSearchTagContentState(to: .found)
        case .failure(let error):
          WhistleLogger.logger.error("requestTagSearchedContent(queryString: String) \(error)")
          SearchProgressViewModel.shared.changeSearchTagContentState(to: .notFound)
        }
      }
  }
}
