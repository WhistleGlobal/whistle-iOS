//
//  NotificationListView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/2/23.
//

import Kingfisher
import SwiftUI

// MARK: - NotificationListView

struct NotificationListView: View {

  @State var isFollow = false
  let seprator = SeprateNickAndContent()

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        Divider().foregroundColor(.Disable_Placeholder)
        contentWhistleNotiRow()
        Divider()
          .frame(height: 0.5)
          .padding(.leading, 74)
          .foregroundColor(.Disable_Placeholder)
        contentFollowNotiRow()
        Divider()
          .frame(height: 0.5)
          .padding(.leading, 74)
          .foregroundColor(.Disable_Placeholder)
        contentWhistleNotiRow()
        Divider()
          .frame(height: 0.5)
          .padding(.leading, 74)
          .foregroundColor(.Disable_Placeholder)
      }
    }
    .navigationTitle(CommonWords().notification)
    .onAppear {
      let dateString = "2022-09-02T05:19:19.000Z"
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 시간대를 UTC로 설정

      if let date = dateFormatter.date(from: dateString) {
        print(date) // 날짜가 정상적으로 변환됩니다.
        let testString = Date.timeAgoSinceDate(date)
        print(testString)
      } else {
        print("날짜 변환에 실패했습니다.")
      }
      seprator.seprateNickAndContent()
      print("Nickname: \(seprator.nickname)")
      print("Content: \(seprator.content)")
    }
  }
}

#Preview {
  NavigationStack {
    NotificationListView()
  }
}

extension NotificationListView {
  @ViewBuilder
  func contentWhistleNotiRow() -> some View {
    HStack(spacing: 0) {
      Group {
        profileImageView(url: "https://picsum.photos/id/237/200/300", size: 48)
          .padding(.trailing, 10)
        Group {
          Text("Whistle")
            .font(.system(size: 14, weight: .semibold)) +
            Text("님이 회원님의 게시물에 휘슬을 보냈습니다.  ")
            .font(.system(size: 14)) +
            Text("3개월 전")
            .font(.caption)
            .foregroundColor(Color.Disable_Placeholder_Dark)
        }
        .lineSpacing(6)
        .padding(.vertical, 3)
        .foregroundColor(.LabelColor_Primary)
        Spacer()
        KFImage.url(URL(string: "https://picsum.photos/id/237/200/300"))
          .placeholder { // 플레이스 홀더 설정
            Color.black
          }
          .resizable()
          .frame(width: 55, height: 55)
          .scaledToFit()
          .cornerRadius(8)
      }
      .onTapGesture {
        print("tap")
        guard let url = URL(string: "https://readywhistle.com/profile_uni?id=7") else { return }
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
      }
    }
    .frame(height: 72)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  func contentFollowNotiRow() -> some View {
    HStack(spacing: 0) {
      profileImageView(url: "https://picsum.photos/id/237/200/300", size: 48)
        .padding(.trailing, 10)
      Group {
        Text("Whistle")
          .font(.system(size: 14, weight: .semibold)) +
          Text("님이 회원님을 팔로우하기 시작했습니다.  ")
          .font(.system(size: 14)) +
          Text("3개월 전")
          .font(.caption)
          .foregroundColor(Color.Disable_Placeholder_Dark)
      }
      .lineSpacing(6)
      .padding(.vertical, 3)
      .foregroundColor(.LabelColor_Primary)
      Spacer()
      followButton(isFollow: isFollow)
    }
    .frame(height: 72)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  func followButton(isFollow: Bool) -> some View {
    Button {
      print("Nickname: \(seprator.nickname)")
      print("Content: \(seprator.content)")
      self.isFollow.toggle()
    } label: {
      Text(isFollow ? CommonWords().following : CommonWords().follow)
        .fontSystem(fontDesignSystem: .caption_SemiBold)
        .foregroundColor(
          isFollow
            ? .LabelColor_DisablePlaceholder
            : .LabelColor_Primary_Dark)
          .frame(width: 58, height: 26)
          .background {
            Capsule()
              .foregroundColor(isFollow ? .white : .Primary_Default)
              .overlay {
                if isFollow {
                  Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.LabelColor_DisablePlaceholder)
                }
              }
          }
    }
  }
}

// MARK: - SeprateNickAndContent

class SeprateNickAndContent {
  var nickname = ""
  var content = ""
  var givenText = "Whistle님이 회원님의 게시물에 휘슬을 보냈습니다"

  func seprateNickAndContent() {
    if let range = givenText.range(of: "님이") {
      nickname = String(givenText[..<range.lowerBound])
      content = String(givenText[range.lowerBound...])
    } else {
      print("텍스트 분리에 문제가 있습니다.")
    }
  }
}


extension Date {
  static func timeAgoSinceDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour], from: date, to: now)

    if let year = components.year, year > 0 {
      return "\(year)년 전"
    }

    if let month = components.month, month > 0 {
      return "\(month)달 전"
    }

    if let week = components.weekOfYear, week > 0 {
      return "\(week)주 전"
    }

    if let day = components.day, day > 0 {
      return "\(day)일 전"
    }

    if let hour = components.hour, hour > 0 {
      return "\(hour)시간 전"
    }
    return "방금 전"
  }
}
