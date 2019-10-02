//
//  YoutubePlayer.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/16.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation
import XCDYouTubeKit
import AVKit
import CoreData

class YoutubePlayer {
  
  static var shared = YoutubePlayer()
  
  private let commandCenter = MPRemoteCommandCenter.shared()
  private let youtubeClient = XCDYouTubeClient(languageIdentifier: "zh")
  private var isPlaying = false
  private var isExtendingBGJob = false
  var youtubePlayerVC: AVPlayerViewController?
  var youtubeAVPlayer: AVPlayer?
  var setUpYoutubePlayerVCCompletionHandler: ((AVPlayerViewController) -> Void)?
  private var coredataConnect = CoreDataConnect()
  var video: Video? {
    didSet {
      getAndSaveVideoInfomation()
    }
  }
  private var streamURL: URL?
  
  private init() { }
  
  func getAndSaveVideoInfomation() {
    youtubePlayerVC = AVPlayerViewController()
    youtubeClient.getVideoWithIdentifier(video!.youtubeID) { [weak self] youtubeVideo, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        logger.log(error.debugDescription, level: .error)
        return
      }
      guard let youtubeVideo = youtubeVideo else {
        assertionFailure()
        return
      }
      let streamURLs = youtubeVideo.streamURLs
      if let tempStreamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
        self.streamURL = tempStreamURL
//        self.saveVideoInforamation(youtubeVideo: youtubeVideo)
        self.youtubeAVPlayer = AVPlayer(url: tempStreamURL)
        self.youtubePlayerVC?.player = self.youtubeAVPlayer
        self.setUpYoutubePlayerVCCompletionHandler?(self.youtubePlayerVC!)
        if let url = youtubeVideo.thumbnailURL {
          ImageLoader.shared.imageByURL(url) {
            _, _ in
          }
        }
      }
    }
  }
  
  private func saveVideoInforamation(youtubeVideo: XCDYouTubeVideo) {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), video!.youtubeID)
    do {
      try coredataConnect.update(type: Video.self, predicate: predicate, limit: 1, attributeInfo: [
        #keyPath(Video.name) : youtubeVideo.title as Any,
        #keyPath(Video.thumbnailURL) : youtubeVideo.thumbnailURL!.absoluteString as Any,
        #keyPath(Video.url) : self.streamURL!.absoluteString as Any,
        #keyPath(Video.duration) : youtubeVideo.duration as Any,
        ])
    } catch {
      logger.log(error, level: .error)
    }
  }
  
  func play(video: Video, setUpYoutubePlayerVCCompletionHandler: ((AVPlayerViewController) -> Void)?) {
    self.setUpYoutubePlayerVCCompletionHandler = setUpYoutubePlayerVCCompletionHandler
    self.video = video
    setupRemoteCommandCenter()
    setupNowPlayingInfo()
  }
  
  private func setupRemoteCommandCenter() {
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true
    
    commandCenter.playCommand.addTarget { [weak self] event in
      guard let self = self else { return .commandFailed }
      
      guard let player = self.youtubePlayerVC?.player else { return .commandFailed }
      guard player.rate == 0 else {
        return .success
      }
      player.play()
      guard player.rate == 1 else {
        return .commandFailed
      }
      return .success
    }
    
    commandCenter.pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
      guard let self = self else { return .commandFailed }
      guard let player = self.youtubePlayerVC?.player else { return .commandFailed }
      guard player.rate == 1 else {
        return .success
      }
      player.pause()
      guard player.rate == 0 else {
        return .commandFailed
      }
      return .success
    }
  }
  
  func setupNowPlayingInfo() {
    guard let video = video else {
      fatalError()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now()) {   // 要放在main thread才能更新remote center UI, 延後一秒，等songItem 準備好
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: video.name!,
        MPMediaItemPropertyPlaybackDuration: video.duration
      ]
      
      func setMPMediaItemPropertyArtwork(image: UIImage) {
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in
          return image
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
      }
      // TODO： MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: CMTimeGetSeconds(songItem.currentTime()))
      if let thumbnailString = video.thumbnailURL, let thumbnailURL = URL(string: thumbnailString) {
        ImageLoader.shared.imageByURL(thumbnailURL, completionHandler: { image, _ in
          guard let image = image else {
            logger.log("No Image", level: .debug)
            return
          }
          setMPMediaItemPropertyArtwork(image: image)
        })
      } else {
        // 無縮圖用 soso 美照
        let image = UIImage(named: "Soso")!
        setMPMediaItemPropertyArtwork(image: image)
      }
    }
  }
}

// MARK: - App in Background Mode
// https://developer.apple.com/library/archive/qa/qa1668/_index.html#//apple_ref/doc/uid/DTS40010209-CH1-VIDEO
extension YoutubePlayer {
  func setVideoTrack(_ isEnable: Bool) {
    if let player = youtubeAVPlayer {
      if let playerItem = player.currentItem {
        let tracks = playerItem.tracks
        for playerItemTrack in tracks {
            // Find the video tracks.
          if playerItemTrack.assetTrack?.hasMediaCharacteristic(AVMediaCharacteristic.visual) == true {
                // Disable the track.
                playerItemTrack.isEnabled = isEnable
            }
        }
      }
    }
  }
}

struct YouTubeVideoQuality {
  static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
  static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
  static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}
