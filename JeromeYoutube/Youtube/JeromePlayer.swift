// JeromePlayer.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import AVKit
import CoreData
import Foundation
import XCDYouTubeKit

typealias YoutubePlayerIsRedayHandler = (AVPlayerLayer) -> Void

class JeromePlayer {
  static var shared = JeromePlayer()

  private let commandCenter = MPRemoteCommandCenter.shared()
  private let youtubeClient = XCDYouTubeClient(languageIdentifier: "zh")
  private var coreDataConnect = CoreDataConnect()

  // Current Playing Video
  var isPlaying: Bool {
    guard let player = self.theAVPlayer else { return false }
    if player.rate == 0 {
      return false
    } else {
      return true
    }
  }
  
  private var isExtendingBGJob = false
  var theAVPlayer: AVPlayer?
  var theAVPlayerLayer: AVPlayerLayer?
  var youtubePlayerIsRedayHandler: YoutubePlayerIsRedayHandler?
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
    guard let youtubeIDNotNil = aVideo.youtubeID else {
      fatalError()
    }
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeIDNotNil)
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

  func resetPlayer() {
    isExtendingBGJob = false
    theAVPlayer?.pause()
    theAVPlayer = nil
    theAVPlayerLayer = nil
    youtubePlayerIsRedayHandler = nil
    video = nil
  }
  
  func play(video: Video, youtubePlayerIsRedayHandler: YoutubePlayerIsRedayHandler? = nil) {
    resetPlayer()
    self.youtubePlayerIsRedayHandler = youtubePlayerIsRedayHandler
    self.video = video
    
    if video.savePlace == 0 {
      // Local Music
      let bundle = BundleManager.musicsBundle
      let url = bundle.url(forResource: video.url!, withExtension: nil)!
      theAVPlayer = AVPlayer(url: url)
      theAVPlayer?.play()
    } else {
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
          self.theAVPlayer = AVPlayer(url: tempStreamURL)
          self.theAVPlayerLayer = AVPlayerLayer(player: self.theAVPlayer)
          self.youtubePlayerIsRedayHandler?(self.theAVPlayerLayer!)
          self.theAVPlayer?.play()
        }
      }
    }
//    youtubePlayerVC = JePlayerVC()
//    youtubePlayerVC?.onDismiss = { [weak self] in
//      guard let self = self else { return }
//      self.resetPlayer()
//    }
    
    setupRemoteCommandCenter()
    setupNowPlayingInfo()
  }
  
  func pause() {
    guard let player = self.theAVPlayer else { return }
    guard player.rate != 0 else {
      return
    }
    player.pause()
  }

  func continuePlaying() {
    guard let player = self.theAVPlayer else { return }
    guard player.rate == 0 else {
      return
    }
    player.play()
  }
  
  private func setupRemoteCommandCenter() {
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true

    commandCenter.playCommand.addTarget { [weak self] _ in
      guard let self = self else { return .commandFailed }

      guard let player = self.theAVPlayer else { return .commandFailed }
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
      guard let player = self.theAVPlayer else { return .commandFailed }
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
        let image = UIImage(systemName: "photo")!
        setMPMediaItemPropertyArtwork(image: image)
      }
    }
  }
}

// MARK: - App in Background Mode

// https://developer.apple.com/library/archive/qa/qa1668/_index.html#//apple_ref/doc/uid/DTS40010209-CH1-VIDEO
extension JeromePlayer {
  func setVideoTrack(_ isEnable: Bool) {
    if let player = theAVPlayer {
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
