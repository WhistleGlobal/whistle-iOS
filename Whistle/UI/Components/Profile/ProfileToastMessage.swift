//
//  ProfileToastMessage.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

struct ProfileToastMessage: View {
    let text: String
    @Binding var showToast: Bool
    @State private var toastOpacity: Double = 0.0

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(8)
                .opacity(toastOpacity)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .onAppear {
            // showToast가 true로 설정되면 토스트 메시지를 표시하도록 설정
            if showToast {
                toastOpacity = 1.0
                // 일정 시간 후에 토스트 메시지를 숨김
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        toastOpacity = 0.0
                    }
                    // showToast를 false로 설정하여 다음에 토스트 메시지가 나타나지 않도록 함
                    showToast = false
                }
            }
        }
    }
}

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


#Preview {
    ProfileToastMessage(text: "Hello, World!", showToast: .constant(true))
}
