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
  // MARK: Public

  public enum InputValidationStatus: String {
    case valid
    case empty
    case tooShort
    case invalidCharacters
    case invalidID
    case updateFailed
    case none
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared

  @State var inputValidationStatus: InputValidationStatus = .none
  @State var isAlertActive = false
  @State var originalUsername = ""

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("사용자 ID를 입력해주세요.", text: $apiViewModel.myProfile.userName)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .tint(.Info)
        .modifier(ClearButton(text: $apiViewModel.myProfile.userName))
        .onReceive(Just(apiViewModel.myProfile.userName).delay(for: 0.5, scheduler: RunLoop.current)) { _ in
          Task {
            if originalUsername != apiViewModel.myProfile.userName {
              inputValidationStatus = await validateInput(apiViewModel.myProfile.userName)
            }
          }
        }
      Divider().frame(width: UIScreen.width)
      if inputValidationStatus != .none {
        validationLabel()
      }
      Text("사용자 ID는 영문, 숫자, 밑줄 및 마침표만 포함 가능하며 4자 이상 16자 이하로 입력해주세요. 사용자 ID를 변경하면 프로필 링크도 변경되며 14일마다 한 번씩 ID를 변경할 수 있습니다.")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.leading)
        .lineLimit(4)
        .padding(.vertical, 12)
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .overlay {
      AlertPopup(
        alertStyle: .linear,
        title: "정말 사용자 ID를\n 변경하시겠습니까?",
        content: "14일마다 한 번씩 사용자 ID를\n 변경할 수 있습니다.",
        cancelText: "취소",
        destructiveText: "변경")
      {
        isAlertActive = false
      } destructiveAction: {
        Task {
          let updateStatus = await apiViewModel.updateMyProfile()
          if updateStatus == .valid {
            toastViewModel.toastInit(message: "사용자 ID가 수정되었습니다.", padding: 32)
            dismiss()
          } else {
            inputValidationStatus = updateStatus
            isAlertActive = false
            originalUsername = apiViewModel.myProfile.userName
          }
        }
      }
      .opacity(isAlertActive ? 1 : 0)
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          Task {
            await apiViewModel.requestMyProfile()
            dismiss()
          }
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
          Task {
            isAlertActive = true
          }
        } label: {
          Text("완료")
            .foregroundColor(inputValidationStatus == .valid ? .Info : .Disable_Placeholder)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
        .disabled(inputValidationStatus != .valid)
        .disabled(isAlertActive)
        .opacity(isAlertActive ? 0 : 1)
      }
    }
    .onAppear {
      originalUsername = apiViewModel.myProfile.userName
      tabbarModel.tabbarOpacity = 0.0
    }
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

  func validateInput(_ input: String) async -> InputValidationStatus {
    if input.isEmpty {
      return InputValidationStatus.empty
    }
    if input.count < 4 {
      return InputValidationStatus.tooShort
    }

    let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._")
    let inputCharacterSet = CharacterSet(charactersIn: input)
    if !allowedCharacterSet.isSuperset(of: inputCharacterSet) {
      return InputValidationStatus.invalidCharacters
    }

    if await apiViewModel.isAvailableUsername() {
      return InputValidationStatus.valid
    } else {
      return InputValidationStatus.invalidID
    }
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
      "사용할 수 있는 ID 입니다."
    case .empty:
      "사용자 ID를 입력해주세요."
    case .tooShort:
      "사용자 ID는 4자 이상 입력해주세요."
    case .invalidCharacters:
      "영문, 숫자, 밑줄 또는 마침표만 허용됩니다."
    case .invalidID:
      "이미 사용 중인 ID 입니다."
    case .none:
      ""
    case .updateFailed:
      "사용자 이름은 14일에 한번만 업데이트할 수 있습니다."
    }
  }

  func validationColor() -> Color {
    switch inputValidationStatus {
    case .valid, .none:
      .Success
    case .empty, .tooShort, .invalidCharacters, .invalidID, .updateFailed:
      .Danger
    }
  }

  func validationSystemImagename() -> String {
    switch inputValidationStatus {
    case .valid, .none:
      "checkmark.circle"
    case .empty, .tooShort, .invalidCharacters, .invalidID, .updateFailed:
      "exclamationmark.triangle.fill"
    }
  }
}
