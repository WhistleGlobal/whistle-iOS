//
//  ProfileEditIDView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import Combine
import SwiftUI

// MARK: - ProfileEditIDView

struct ProfileEditIDView: View {

  enum InputValidationStatus: String {
    case valid
    case empty
    case tooShort
    case invalidCharacters
    case invalidID
    case none
  }

  @Environment(\.dismiss) var dismiss
  @State var inputID = ""
  @State var inputValidationStatus: InputValidationStatus = .valid
  @Binding var showToast: Bool


  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("사용자 ID를 입력해주세요.", text: $inputID)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .modifier(ClearButton(text: $inputID))
        .background(.white)
        .onReceive(Just(inputID).debounce(for: 0.5, scheduler: RunLoop.main)) { newText in
          inputValidationStatus = validateInput(newText)
        }
      Divider().frame(width: UIScreen.width)
      if inputValidationStatus != .none {
        validationLabel()
      }
      Text("사용자 ID는 영문, 숫자, 밑줄 및 마침표만 포함 가능하며 2자 이상 16자 이하로 입력해주세요. 사용자 ID를 변경하면 프로필 링크도 변경되며 30일마다 한 번씩 ID를 변경할 수 있습니다.")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.leading)
        .lineLimit(4)
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("사용자 ID")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          log("Update Profile")
          dismiss()
          showToast = true
        } label: {
          Text("완료")
            .foregroundColor(inputValidationStatus == .valid ? .Info : .Disable_Placeholder)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
        .disabled(inputValidationStatus != .valid)
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProfileEditIDView(showToast: .constant(true))
  }
}

extension ProfileEditIDView {

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

  func validateInput(_ input: String) -> InputValidationStatus {
    if input.isEmpty {
      return .empty
    }
    if input.count < 3 {
      return .tooShort
    }

    let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._")
    let inputCharacterSet = CharacterSet(charactersIn: input)
    if !allowedCharacterSet.isSuperset(of: inputCharacterSet) {
      return .invalidCharacters
    }
    // TODO: - 중복 아이디 조건
    //        if false {
    //            return .invalidID
    //        }

    return .valid
  }

  @ViewBuilder
  func validationLabel() -> some View {
    Label(validationText(), systemImage: validationSystemImagename())
      .fontSystem(fontDesignSystem: .body2_KO)
      .foregroundColor(validationColor())
      .frame(height: 42)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  func validationText() -> String {
    switch inputValidationStatus {
    case .valid:
      return "사용할 수 있는 ID 입니다."
    case .empty:
      return "사용자 ID를 입력해주세요."
    case .tooShort:
      return "사용자 ID는 2자 이상 입력해주세요."
    case .invalidCharacters:
      return "영문, 숫자, 밑줄 또는 마침표만 허용됩니다."
    case .invalidID:
      return "이미 사용 중인 ID 입니다."
    case .none:
      return ""
    }
  }

  func validationColor() -> Color {
    switch inputValidationStatus {
    case .valid, .none:
      return .Success
    case .empty, .tooShort, .invalidCharacters, .invalidID:
      return .Danger
    }
  }

  func validationSystemImagename() -> String {
    switch inputValidationStatus {
    case .valid, .none:
      return "checkmark.circle"
    case .empty, .tooShort, .invalidCharacters, .invalidID:
      return "exclamationmark.triangle.fill"
    }
  }
}
