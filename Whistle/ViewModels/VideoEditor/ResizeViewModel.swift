////
////  ResizeViewModel.swift
////  Whistle
////
////  Created by 박상원 on 2023/09/29.
////
//
// import AVFoundation
// import UIKit
//
// class ResizeViewModel: ObservableObject {
//  var asset: AVAsset?
//  var videoURL: URL
//  var resizeWidth: CGFloat?
//  var resizeHeight: CGFloat?
//  let resizeScale: CGFloat = 16 / 9
//
//  init(videoURL: URL, resizeHeight _: CGFloat) {
//    self.videoURL = videoURL
//    asset = AVAsset(url: videoURL)
//    resizeHeight = resizeScale * resizeWidth!
//  }
//
//  func resizeVideo() async {
//    // 동영상 파일의 URL
////    videoURL = URL(fileURLWithPath: "your_video_file_path")
//
//    // AVAsset 초기화
////    let asset = AVAsset(url: videoURL)
//
//    Task {
//      if let originalVideoTrack = try await asset?.loadTracks(withMediaType: .video).first {
//        asset = originalVideoTrack.asset
//        var naturalSize = await asset?.naturalSize()
//        resizeHeight = resizeWidth! * resizeScale
//
//        // Composition 초기화
//        let composition = AVMutableComposition()
//
//        // 비디오 트랙 생성
//        if let resizedVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        {
//          try await resizedVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset!.load(.duration)), of: asset!.loadTracks(withMediaType: .video)[0], at: .zero)
//          let frameRate = try await originalVideoTrack.load(.nominalFrameRate)
//          if let newVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//          {
//            try await newVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset!.load(.duration)), of: resizedVideoTrack, at: .zero)
//            newVideoTrack.preferredTransform = CGAffineTransform(scaleX: 1, y: height / naturalSize!.height)
//          }
//
//        } else {}
//
//      } else {}
//    }
////    try! videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset!.duration), of: asset!.tracks(withMediaType: .video)[0], at: .zero)
//    // 새 비디오 크기 설정 (가로 크기는 기존 크기를 유지하고, 위아래 여백을 추가)
//    let width = asset?.tracks(withMediaType: AVMediaType.video)[0].naturalSize.width
//    let height = (asset?.tracks(withMediaType: AVMediaType.video)[0].naturalSize.height)! + 100 // 여백 크기 조절
//
//    let composition = AVMutableComposition()
//
//    // 비디오 트랙의 프레임 속성 가져오기
////    let videoSize = videoTrack?.naturalSize
////    let frameRate = videoTrack?.nominalFrameRate
////
////    // 새 비디오 트랙 생성 (크기 조정)
////    let newVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
////    try! newVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset!.duration), of: videoTrack!, at: .zero)
////
////    // 새로운 비디오 트랙의 프레임 속성 설정 (크기 조정)
////    newVideoTrack?.preferredTransform = CGAffineTransform(scaleX: 1, y: height / videoSize!.height)
////
////    // 비디오 출력 설정
////    let videoSettings: [String: Any] = [
////      AVVideoCodecKey: AVVideoCodecType.h264,
////      AVVideoWidthKey: width,
////      AVVideoHeightKey: height,
////    ]
////
////    let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
////    videoInput.expectsMediaDataInRealTime = false
////
////    let videoOutput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
////
////    // 비디오 출력 파일 경로
////    let outputPath = URL(fileURLWithPath: "output_video_path")
////
////    // 비디오 출력 초기화
////    let assetWriter = try! AVAssetWriter(outputURL: outputPath, fileType: .mp4)
////    assetWriter.add(videoInput)
////
////    // 동영상을 수정하여 저장
////    assetWriter.startWriting()
////    assetWriter.startSession(atSourceTime: .zero)
////
////    let group = DispatchGroup()
////
////    let videoQueue = DispatchQueue.global(qos: .default)
////
////    videoInput.requestMediaDataWhenReady(on: videoQueue) {
////      while videoInput.isReadyForMoreMediaData {
////        let nextBuffer = videoOutput.copyNextSampleBuffer()
////        if nextBuffer != nil {
////          videoInput.append(nextBuffer!)
////        } else {
////          videoInput.markAsFinished()
////          assetWriter.finishWriting {
////            if assetWriter.error == nil {
////              print("Video editing completed.")
////            } else {
////              print("Video editing error: \(assetWriter.error!)")
////            }
////          }
////        }
////      }
////    }
////
////    group.wait()
//  }
// }
