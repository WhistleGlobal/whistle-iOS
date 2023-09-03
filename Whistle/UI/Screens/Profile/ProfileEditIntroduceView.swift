//
//  ProfileEditIntroduceView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileEditIntroduceView

struct ProfileEditIntroduceView: View {

  @Environment(\.dismiss) var dismiss
  @State var inputIntroduce = ""

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("소개글을 입력해주세요. (40자 내)", text: $inputIntroduce)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .modifier(ClearButton(text: $inputIntroduce))
        .background(.white)
      Divider().frame(width: UIScreen.width)
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("소개")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          log("Update Profile")
          dismiss()
        } label: {
          Text("완료")
            .foregroundColor(true ? .Info : .Disable_Placeholder)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
        .disabled(false)
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProfileEditIntroduceView()
  }
}

extension ProfileEditIntroduceView {

  // MARK: - ClearButton

  struct ClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
      HStack {
        content
        Button(action: {
          text = ""
        }) {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(.Dim_Default)
            .opacity(text.isEmpty ? 0 : 1)
        }
      }
    }
  }
}
