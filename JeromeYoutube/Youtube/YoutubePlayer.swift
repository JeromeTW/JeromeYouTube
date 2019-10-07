// YoutubePlayer.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import AVKit
import CoreData
import Foundation
import XCDYouTubeKit

class YoutubePlayer {
  static var shared = YoutubePlayer()

  private let commandCenter = MPRemoteCommandCenter.shared()
  private let youtubeClient = XCDYouTubeClient(languageIdentifier: "zh")
  private var coreDataConnect = CoreDataConnect()

  // Current Playing Video
  private var streamURL: URL?
  var isPlaying = false
  private var isExtendingBGJob = false
  var youtubePlayerVC: JePlayerVC?
  var youtubeAVPlayer: AVPlayer?
  var setUpYoutubePlayerVCCompletionHandler: ((JePlayerVC) -> Void)?
  var video: Video?

  private init() {}

  func getAndSaveVideoInfomation(_ aVideo: Video) {
    youtubeClient.getVideoWithIdentifier(aVideo.youtubeID) { [weak self] youtubeVideo, error in
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
      self.saveVideoInforamation(aVideo, youtubeVideo: youtubeVideo)
    }
  }

  private func saveVideoInforamation(_ aVideo: Video, youtubeVideo: XCDYouTubeVideo) {
    let streamURLs = youtubeVideo.streamURLs
    guard let tempStreamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) else {
      fatalError()
    }
    if let url = youtubeVideo.thumbnailURL {
      ImageLoader.shared.imageByURL(url)
    }
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), aVideo.youtubeID)
    do {
      try coreDataConnect.update(type: Video.self, predicate: predicate, limit: 1, attributeInfo: [
        #keyPath(Video.name): youtubeVideo.title as Any,
        #keyPath(Video.thumbnailURL): youtubeVideo.thumbnailURL!.absoluteString as Any,
        #keyPath(Video.url): tempStreamURL.absoluteString as Any,
        #keyPath(Video.duration): youtubeVideo.duration as Any,
      ])
    } catch {
      logger.log(error, level: .error)
    }
  }

  private func resetPlayer() {
    streamURL = nil
    isPlaying = false
    isExtendingBGJob = false
    youtubePlayerVC = nil
    youtubeAVPlayer?.pause()
    youtubeAVPlayer = nil
    setUpYoutubePlayerVCCompletionHandler = nil
    video = nil
  }
  
  func play(video: Video, setUpYoutubePlayerVCCompletionHandler: ((JePlayerVC) -> Void)?) {
    resetPlayer()
    self.setUpYoutubePlayerVCCompletionHandler = setUpYoutubePlayerVCCompletionHandler
    self.video = video
    
    youtubePlayerVC = JePlayerVC()
    youtubePlayerVC?.onDismiss = { [weak self] in
      guard let self = self else { return }
      self.resetPlayer()
    }
    
    youtubeClient.getVideoWithIdentifier(video.youtubeID) { [weak self] youtubeVideo, error in
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
        self.youtubeAVPlayer = AVPlayer(url: tempStreamURL)
        self.youtubePlayerVC?.player = self.youtubeAVPlayer
        self.setUpYoutubePlayerVCCompletionHandler?(self.youtubePlayerVC!)
      }
    }
    
    setupRemoteCommandCenter()
    setupNowPlayingInfo()
  }

  private func setupRemoteCommandCenter() {
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true

    commandCenter.playCommand.addTarget { [weak self] _ in
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

    commandCenter.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
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

    DispatchQueue.main.asyncAfter(deadline: .now()) { // 要放在main thread才能更新remote center UI, 延後一秒，等songItem 準備好
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: video.name!,
        MPMediaItemPropertyPlaybackDuration: video.duration,
      ]

      func setMPMediaItemPropertyArtwork(image: UIImage) {
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
          image
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
