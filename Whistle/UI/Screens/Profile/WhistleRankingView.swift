//
//  WhistleRankingView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/19/23.
//

import Foundation
import Mixpanel
import SwiftUI

// MARK: - WhistleRankingView

struct WhistleRankingView: View {

  @StateObject var bartintModel = BarTintModel.shared
  @StateObject var apiViewModel = APIViewModel.shared
  let userID: Int
  let userName: String

  init(userID: Int = 0, userName: String = "") {
    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    self.userID = userID
    self.userName = userName
  }

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
      }
      .ignoresSafeArea()
      VStack(spacing: 0) {
        VStack(spacing: 40) {
          Text("\(userName)님의 휘슬 수는")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 15)
          HStack(spacing: 0) {
            Image(systemName: "trophy.fill")
              .font(.system(size: 20, weight: .semibold))
              .padding(.trailing, 10)
              .foregroundColor(Color("Gray30").opacity(30))
            Text("상위 \(apiViewModel.rankingModel.userRanking.percentile)%")
              .fontSystem(fontDesignSystem: .title1_SemiBold)
            Spacer()
            Text("\(apiViewModel.rankingModel.userRanking.totalWhistle.roundedWithAbbreviations)")
              .fontSystem(fontDesignSystem: .subtitle3)
            Image(systemName: "heart.fill")
              .fontSystem(fontDesignSystem: .subtitle3)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 15)
        }
        .foregroundColor(.white)
        .frame(width: UIScreen.width - 32, height: 130)
        .background {
          glassMorphicDarkView(cornerRadius: 20)
            .overlay {
              RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 1)
                .foregroundStyle(
                  LinearGradient.Border_Glass)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        ScrollView {
          VStack(spacing: 0) {
            ForEach(Array(apiViewModel.rankingModel.topRankings.enumerated()), id: \.element) { index, item in
              if apiViewModel.myProfile.userId == item.userId {
                myRankingRow(ranking: index + 1, userName: item.userName, myTeam: item.myTeam, whistleCount: item.totalWhistle)
              } else {
                rankingRow(
                  ranking: index + 1,
                  userName: item.userName,
                  myTeam: item.myTeam,
                  whistleCount: item.totalWhistle,
                  profileImageURL: item.profileImg)
              }
              if index != apiViewModel.rankingModel.topRankings.count - 1 {
                Divider()
                  .frame(height: 0.5)
                  .padding(.horizontal, 16)
                  .foregroundColor(.labelColorDisablePlaceholder)
              }
            }
          }
          .background {
            glassMorphicDarkView(cornerRadius: 20)
              .overlay {
                RoundedRectangle(cornerRadius: 20)
                  .stroke(lineWidth: 1)
                  .foregroundStyle(
                    LinearGradient.Border_Glass)
              }
              .padding(.horizontal, 16)
          }
          Spacer().frame(height: 100)
        }
        .scrollIndicators(.hidden)
        .padding(.top, 10)
      }
      VStack {
        Spacer()
        LinearGradient(
          colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)],
          startPoint: .top,
          endPoint: .bottom)
          .frame(height: 140)
      }.ignoresSafeArea()
    }
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(CommonWords().whistle)
          .foregroundStyle(Color.labelColorPrimary)
          .font(.headline)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .ignoresSafeArea(edges: .horizontal)
    .task {
      apiViewModel.requestRankingList(userID: userID)
    }
    .onAppear {
      bartintModel.tintColor = .white
      UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
      Mixpanel.mainInstance().track(event: "view_whistlerank")
    }
    .onDisappear {
      bartintModel.tintColor = .labelColorPrimary
      UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.labelColorPrimary)]
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.labelColorPrimary)]
    }
  }
}

extension WhistleRankingView {

  @ViewBuilder
  func rankingRow(ranking: Int, userName: String, myTeam: String?, whistleCount: Int, profileImageURL: String?) -> some View {
    HStack(spacing: 0) {
      Text("\(ranking)")
        .fontSystem(fontDesignSystem: .title1)
        .foregroundColor(.white)
        .frame(width: 32, height: 36)
        .padding(.trailing, 10)
      profileImageView(url: profileImageURL, size: 48)
        .padding(.trailing, 20)
      VStack(alignment: .leading, spacing: 0) {
        Text(userName)
          .fontSystem(fontDesignSystem: .subtitle2)
        if let team = myTeam {
          Text(team)
            .fontSystem(fontDesignSystem: .body2)
        }
      }
      Spacer()
      Text("\(whistleCount.roundedWithAbbreviations)")
        .fontSystem(fontDesignSystem: .subtitle3)
      Image(systemName: "heart.fill")
        .fontSystem(fontDesignSystem: .subtitle3)
    }
    .frame(height: 84)
    .padding(.horizontal, 36)
    .foregroundColor(.white)
  }

  @ViewBuilder
  func myRankingRow(ranking: Int, userName: String, myTeam: String?, whistleCount: Int) -> some View {
    HStack(spacing: 0) {
      Text("\(ranking)")
        .fontSystem(fontDesignSystem: .title1)
        .foregroundColor(.white)
        .frame(width: 32, height: 36)
        .padding(.trailing, 10)
        .padding(.leading, 20)
      profileImageView(url: apiViewModel.myProfile.profileImage, size: 48)
        .padding(.trailing, 20)
      VStack(alignment: .leading, spacing: 0) {
        Text(userName)
          .fontSystem(fontDesignSystem: .subtitle2)
        if let team = myTeam {
          Text(team)
            .fontSystem(fontDesignSystem: .body2)
        }
      }
      Spacer()
      Text("\(whistleCount.roundedWithAbbreviations)")
        .fontSystem(fontDesignSystem: .subtitle3)
      Image(systemName: "heart.fill")
        .fontSystem(fontDesignSystem: .subtitle3)
        .padding(.trailing, 20)
    }
    .frame(height: 84)
    .padding(.horizontal, 16)
    .foregroundColor(.white)
    .background {
      glassMorphicView(cornerRadius: 16)
        .overlay {
          RoundedRectangle(cornerRadius: 16)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
        }
        .padding(.horizontal, 11)
    }
  }
}
