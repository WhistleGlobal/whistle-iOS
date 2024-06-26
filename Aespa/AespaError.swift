//
//  AespaError.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import Foundation

// MARK: - AespaError

public enum AespaError: LocalizedError {
  case session(reason: SessionErrorReason)
  case device(reason: DeviceErrorReason)
  case permission(reason: PermissionErrorReason)
  case album(reason: AlbumErrorReason)
  case file(reason: FileErrorReason)

  public var errorDescription: String? {
    switch self {
    case .session(reason: let reason):
      reason.rawValue
    case .device(reason: let reason):
      reason.rawValue
    case .permission(reason: let reason):
      reason.rawValue
    case .album(reason: let reason):
      reason.rawValue
    case .file(reason: let reason):
      reason.rawValue
    }
  }
}

extension AespaError {
  public enum SessionErrorReason: String {
    case notConfigured =
      "No camera session was created, please check your camera permissions."
    case notRunning =
      "Session is not running. Check if you've ran the session or permitted camera permissio.n"
    case cannnotFindMovieFileOutput =
      "Couldn't find connected output. Check if you've added connection properly"
    case cannotFindConnection =
      "Couldn't find connection. Check if you've added connection properly"
    case cannotFindDevice =
      "Couldn't find device. Check if you've added device properly"
  }

  public enum DeviceErrorReason: String {
    case invalid =
      "Unable to set up camera device. Please check camera usage permission."
    case unableToSetInput =
      "Unable to set input."
    case outputAlreadyExists =
      "Output is already exists"
    case unableToSetOutput =
      "Unable to set output."
    case notSupported =
      "Unsupported functionality."
    case busy =
      "Device is busy now."
  }

  public enum PermissionErrorReason: String {
    case denied =
      "Cannot take a video because camera permissions are denied."
  }

  public enum AlbumErrorReason: String {
    case unabledToAccess =
      "Unable to access album"
    case videoNotExist =
      "Trying to delete or fetch the video that does not exist."
    case notVideoURL =
      "Received URL is not a video type."
  }

  public enum FileErrorReason: String {
    case unableToFlatten =
      "Cannot take a video because camera permissions are denied."
    case notSupported =
      "Unsuportted file type."
    case alreadyExist =
      "File already exists. Cannot overwrite the file."
  }
}
