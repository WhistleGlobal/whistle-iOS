//
//  VideoViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import Foundation

class VideoVM: ObservableObject {
    // FIXME: - 일단 임시로 제 서버 url로 테스트하는 코드입니다 - 유진
    var currentVideoIndex = 0
    let videoUrls: [String] = [
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
        "http://35.72.228.224/adaStudy/test.mp4",
        "http://35.72.228.224/adaStudy/test2.mp4",
    ]
    
    var videos: [Video] = [
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
        Video(
            player: AVPlayer(url: URL(string: "http://35.72.228.224/adaStudy/test2.mp4")!),
            likes: "1M",
            comments: "22.7k",
            url: "http://35.72.228.224/adaStudy/test.mp4"),
    ]
}
