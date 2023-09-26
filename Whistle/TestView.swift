//
//  TestView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/26/23.
//

import SwiftUI

// MARK: - TestView

struct TestView: View {
  @State var isWhistled = false
  @State var timer: Timer? = nil

  var body: some View {
    VStack {
      Button(action: {
        isWhistled.toggle()
        // 클릭 시 타이머 시작
        startTimer()
      }) {
        Text("클릭하기")
      }
    }
  }

  func startTimer() {
    // 타이머가 이미 실행 중이라면 중지
    timer?.invalidate()

    // 2초 타이머 설정
    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
      print("send to server after 2sec \(isWhistled)")
    }
  }
}

// MARK: - TestView_Previews

struct TestView_Previews: PreviewProvider {
  static var previews: some View {
    TestView()
  }
}


#Preview {
  TestView()
}
