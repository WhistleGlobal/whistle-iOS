//
//  VideoError.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import Foundation

// MARK: - VideoError

public enum VideoError: LocalizedError {
  case session(reason: SessionErrorReason)
  case device(reason: DeviceErrorReason)
  case permission(reason: PermissionErrorReason)
  case album(reason: AlbumErrorReason)

  public var errorDescription: String? {
    switch self {
    case .session(reason: let reason):
      return reason.rawValue
    case .device(reason: let reason):
      return reason.rawValue
    case .permission(reason: let reason):
      return reason.rawValue
    case .album(reason: let reason):
      return reason.rawValue
    }
  }
}

extension VideoError {
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
    case unsupported =
      "Unsupported device (supported on iPhone XR and later devices)"
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
  }
}
