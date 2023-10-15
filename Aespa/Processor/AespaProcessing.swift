//
//  AespaProcessing.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation
import Foundation
import Photos

// MARK: - AespaCapturePhotoOutputProcessing

protocol AespaCapturePhotoOutputProcessing {
  func process<T: AespaPhotoOutputRepresentable>(_ output: T) throws
}

// MARK: - AespaMovieFileOutputProcessing

protocol AespaMovieFileOutputProcessing {
  func process<T: AespaFileOutputRepresentable>(_ output: T) throws
}

// MARK: - AespaAssetProcessing

protocol AespaAssetProcessing {
  func process<Library, Collection>(
    _ library: Library,
    _ collection: Collection) async throws
    where Library: AespaAssetLibraryRepresentable,
    Collection: AespaAssetCollectionRepresentable
}

// MARK: - AespaFileProcessing

protocol AespaFileProcessing {
  func process(_ fileManager: FileManager) throws
}
