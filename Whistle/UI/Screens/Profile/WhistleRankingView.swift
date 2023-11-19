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
              rankingRow()
              if index != 9 {
                Divider()
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
          }
          Spacer().frame(height: 100)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
        .padding(.top, 10)
      }
    }
    .toolbarRole(.editor)
    .navigationTitle(CommonWords().whistle)
    .navigationBarTitleDisplayMode(.inline)
    .ignoresSafeArea(edges: .horizontal)
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
    .padding(.horizontal, 16)
    .foregroundColor(.white)
  }
}
