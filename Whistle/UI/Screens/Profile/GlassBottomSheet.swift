////
////  GlassBottomSheet.swift
////  Whistle
////
////  Created by ChoiYujin on 8/30/23.
////
//
// import SwiftUI
//
//// MARK: - GlassBottomSheet
//
// struct GlassBottomSheet: View {
//  @Binding var isShowing: Bool
//  @Binding var showSignoutAlert: Bool
//  @Binding var showDeleteAlert: Bool
//  @StateObject var apiViewModel = APIViewModel.shared
//  @EnvironmentObject var userAuth: UserAuth
//  var content: AnyView
//
//  var body: some View {
//    ZStack(alignment: .bottom) {
//      if isShowing {
//        Color.black
//          .opacity(0.4)
//          .ignoresSafeArea()
//          .onTapGesture {
//            isShowing.toggle()
//          }
//      }
//      VStack {
//        Spacer()
//        content
//          .frame(height: 450)
//          .transition(.move(edge: .bottom))
//          .background(Color.clear)
//          .offset(y: isShowing ? 0 : 450)
//      }
//      .ignoresSafeArea()
//      .frame(maxWidth: .infinity)
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//    .ignoresSafeArea()
//  }
// }
//
// extension GlassBottomSheet {
//  @ViewBuilder
//  func bottomSheetRowWithIcon(
//    systemName: String,
//    iconWidth: CGFloat,
//    iconHeight: CGFloat,
//    text: String)
//    -> some View
//  {
//    HStack(spacing: 12) {
//      Image(systemName: systemName)
//        .resizable()
//        .scaledToFit()
//        .frame(width: iconWidth, height: iconHeight)
//        .foregroundColor(.white)
//
//      Text(text)
//        .foregroundColor(.white)
//        .fontSystem(fontDesignSystem: .body1_KO)
//      Spacer()
//      Image(systemName: "chevron.forward")
//        .resizable()
//        .scaledToFit()
//        .padding(.vertical, 2.5)
//        .padding(.horizontal, 6)
//        .frame(width: 24, height: 24)
//        .foregroundColor(.white)
//    }
//    .frame(height: 56)
//    .padding(.horizontal, 16)
//  }
//
//  @ViewBuilder
//  func bottomSheetRow(text: String, color: Color) -> some View {
//    HStack {
//      Text(text)
//        .foregroundColor(color)
//        .fontSystem(fontDesignSystem: .body1_KO)
//      Spacer()
//      Image(systemName: "chevron.forward")
//        .resizable()
//        .scaledToFit()
//        .padding(.vertical, 2.5)
//        .padding(.horizontal, 6)
//        .frame(width: 24, height: 24)
//        .foregroundColor(.white)
//    }
//    .frame(height: 56)
//    .padding(.horizontal, 16)
//  }
// }
