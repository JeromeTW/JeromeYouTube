//
//  JeromeYoutubePlayerVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/10.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class JeromeYoutubePlayerVC: XCDYouTubeVideoPlayerViewController {
  
  private let commandCenter = MPRemoteCommandCenter.shared()
  private let youtubeClient = XCDYouTubeClient(languageIdentifier: "zh")
  private var youtubeID: String
  private var streamURL: URL?
  private var playingItem: AVPlayerItem? {
    guard let streamURL = streamURL else {
      return nil
    }
    return AVPlayerItem(url: streamURL)
  }
  
  override init(videoIdentifier: String?) {
    youtubeID = videoIdentifier!
    super.init(videoIdentifier: videoIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupYoutubeClient()
  }
  
  deinit {
    YoutubePlayer.shared.youtubePlayerVC = nil
  }
  
  private func setupYoutubeClient() {
    youtubeClient.getVideoWithIdentifier(youtubeID) { [weak self] video, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        logger.log(error!)
        return
      }
      guard let video = video else {
        assertionFailure()
        return
      }
      let streamURLs = video.streamURLs
      if let tempStreamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
        self.streamURL = tempStreamURL
        self.setupRemoteCommandCenter()
        self.setupNowPlayingInfo(video: video)
      }
    }
  }
  
  private func setupRemoteCommandCenter() {
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true
    
    commandCenter.playCommand.addTarget { [weak self] event in
      guard let self = self else { return .commandFailed }
      guard let player = self.moviePlayer else { return .commandFailed }
      guard player.playbackState != .playing else {
        return .success
      }
      player.play()
      guard player.playbackState == .playing else {
        return .commandFailed
      }
      return .success
    }
    
    commandCenter.pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
      guard let self = self else { return .commandFailed }
      guard let player = self.moviePlayer else { return .commandFailed }
      guard player.playbackState == .playing else {
        return .success
      }
      player.pause()
      guard player.playbackState == .paused else {
        return .commandFailed
      }
      return .success
    }
  }
  
  func setupNowPlayingInfo(video: XCDYouTubeVideo) {
    DispatchQueue.main.asyncAfter(deadline: .now()) {   // 要放在main thread才能更新remote center UI, 延後一秒，等songItem 準備好
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: video.title,
        MPMediaItemPropertyPlaybackDuration: video.duration
      ]
      
      func setMPMediaItemPropertyArtwork(image: UIImage) {
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in
          return image
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
      }
      // TODO： MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: CMTimeGetSeconds(songItem.currentTime()))
      if let thumbnailURL = video.thumbnailURL {
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
