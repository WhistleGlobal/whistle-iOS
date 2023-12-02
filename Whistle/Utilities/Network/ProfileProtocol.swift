//
//  ProfileProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire

protocol ProfileProtocol {
  func requestMyProfile() async
  func updateMyProfile() async -> ProfileEditIDView.InputValidationStatus
  func requestMyWhistlesCount() async
  func requestMyFollow() async
  func isAvailableUsername() async -> Bool
  func deleteProfileImage() async
  func followAction(userID: Int, method: HTTPMethod) async
  func rebokeAppleToken() async
  func blockAction(userID: Int, method: HTTPMethod) async
  func updateMyTeam(myTeam: String) async
  func requestRankingList(userID: Int)
}
