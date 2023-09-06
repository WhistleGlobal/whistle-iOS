//
//  ProfileViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Alamofire
import Foundation
import KeychainSwift

// MARK: - ProfileViewModel

class ProfileViewModel: ObservableObject {
  let keychain = KeychainSwift()
  @Published var myProfile = MyProfile()

  var idToken: String {
    guard let idTokenKey = keychain.get("id_token") else {
      log("id_Token nil")
      return ""
    }
    return idTokenKey
  }

  var domainUrl: String {
    AppKeys.domainUrl as! String
  }
}

// MARK: - 데이터 처리
extension ProfileViewModel {
  func requestMyProfile() async {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/profile",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .responseDecodable(of: MyProfile.self) { response in
        switch response.result {
        case .success(let success):
          self.myProfile = success
        case .failure(let failure):
          log(failure)
        }
      }
  }

  func updateMyProfile() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/x-www-form-urlencoded",
    ]
    let params = [
      "user_name" : "최유진(Eugene)",
      "introduce" : "나는 최유진(Eugene)",
      "country" : "Korea(Korea)",
    ]
    AF.request(
      "\(domainUrl)/user/profile",
      method: .put,
      parameters: params,
      headers: headers)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          // Handle the successful response data here
          if let responseData = data {
            // You can convert responseData to the appropriate type (e.g., JSON) if needed
            print("Success: \(responseData)")
          } else {
            print("Success with no data")
          }

        case .failure(let error):
          // Handle the error here
          print("Error: \(error)")
        }
      }
  }
}
