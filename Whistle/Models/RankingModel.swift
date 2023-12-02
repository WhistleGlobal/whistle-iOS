//
//  RankingModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/24/23.
//

import Foundation

// MARK: - RankingModel

class RankingModel: Decodable, ObservableObject {
  @Published var userRanking = UserRanking()
  @Published var topRankings : [TopRanking] = []

  enum CodingKeys: String, CodingKey {
    case userRanking
    case topRankings
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userRanking = try container.decode(UserRanking.self, forKey: .userRanking)
    topRankings = try container.decode([TopRanking].self, forKey: .topRankings)
  }

  init() { }
}

// MARK: - UserRanking

class UserRanking: Decodable, ObservableObject {
  @Published var percentile = 0
  @Published var totalWhistle = 0

  enum CodingKeys:String, CodingKey {
    case percentile
    case totalWhistle
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    percentile = Int(Double(try container.decode(String.self, forKey: .percentile)) ?? 0.0)
    totalWhistle = try container.decode(Int.self, forKey: .totalWhistle)
  }

  init() { }
}

// MARK: - TopRanking

class TopRanking: Decodable, ObservableObject, Identifiable, Hashable {
  let uuid = UUID()
  @Published var userId = 0
  @Published var userName = ""
  @Published var myTeam: String?
  @Published var totalWhistle = 0
  @Published var profileImg: String?

  enum CodingKeys:String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case myTeam = "myteam"
    case totalWhistle = "total_whistle"
    case profileImg = "profile_img"
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userId = try container.decode(Int.self, forKey: .userId)
    userName = try container.decode(String.self, forKey: .userName)
    myTeam = try container.decode(String?.self, forKey: .myTeam)
    totalWhistle = try container.decode(Int.self, forKey: .totalWhistle)
    profileImg = try container.decode(String?.self, forKey: .profileImg)
  }

  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: TopRanking, rhs: TopRanking) -> Bool {
    lhs.uuid == rhs.uuid
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
