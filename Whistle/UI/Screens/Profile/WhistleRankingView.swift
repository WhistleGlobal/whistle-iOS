//
//  WhistleRankingView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/19/23.
//

import Foundation
import SwiftUI

// MARK: - WhistleRankingView

struct WhistleRankingView: View {

  @StateObject var bartintModel = BarTintModel.shared

  init() {
    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
  }

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("BlurredDefaultBG")
          .resizable()
          .scaledToFill()
      }
      .ignoresSafeArea()
      VStack(spacing: 0) {
        VStack(spacing: 40) {
          Text("ddd님의 휘슬 수는")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 15)
          HStack(spacing: 0) {
            Image(systemName: "trophy.fill")
              .font(.system(size: 20, weight: .semibold))
              .padding(.trailing, 10)
              .foregroundColor(Color("Gray30").opacity(64))
            Text("상위 98%")
              .fontSystem(fontDesignSystem: .title1_SemiBold)
            Spacer()

            Text("\(23.roundedWithAbbreviations)")
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
          glassMorphicView(cornerRadius: 20)
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
            ForEach(0..<10) { index in
              if index == 2 {
                myRankingRow()
              } else {
                rankingRow()
              }
              if index != 9 {
                Divider()
                  .frame(height: 0.5)
                  .padding(.horizontal, 16)
                  .foregroundColor(.labelColorDisablePlaceholder)
              }
            }
          }
          .background {
            glassMorphicView(cornerRadius: 20)
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
    }
    .toolbarRole(.editor)
    .navigationTitle(Text(CommonWords().whistle).foregroundColor(.white))
    .navigationBarTitleDisplayMode(.inline)
    .ignoresSafeArea(edges: .horizontal)
    .onAppear {
      bartintModel.tintColor = .white
      UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
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
  func rankingRow() -> some View {
    HStack(spacing: 0) {
      Text("1")
        .fontSystem(fontDesignSystem: .title1)
        .foregroundColor(.white)
        .frame(width: 32, height: 36)
        .padding(.trailing, 10)
      profileImageView(url: "", size: 48)
        .padding(.trailing, 20)
      VStack(alignment: .leading, spacing: 0) {
        Text("UserName")
          .fontSystem(fontDesignSystem: .subtitle2)
        Text("두산 베어스")
          .fontSystem(fontDesignSystem: .body2)
      }
      Spacer()
      Text("\(1500000.roundedWithAbbreviations)")
        .fontSystem(fontDesignSystem: .subtitle3)
      Image(systemName: "heart.fill")
        .fontSystem(fontDesignSystem: .subtitle3)
    }
    .frame(height: 84)
    .padding(.horizontal, 36)
    .foregroundColor(.white)
  }

  @ViewBuilder
  func myRankingRow() -> some View {
    HStack(spacing: 0) {
      Text("1")
        .fontSystem(fontDesignSystem: .title1)
        .foregroundColor(.white)
        .frame(width: 32, height: 36)
        .padding(.trailing, 10)
        .padding(.leading, 20)
      profileImageView(url: "", size: 48)
        .padding(.trailing, 20)
      VStack(alignment: .leading, spacing: 0) {
        Text("UserName")
          .fontSystem(fontDesignSystem: .subtitle2)
        Text("두산 베어스")
          .fontSystem(fontDesignSystem: .body2)
      }
      Spacer()
      Text("\(1500000.roundedWithAbbreviations)")
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
