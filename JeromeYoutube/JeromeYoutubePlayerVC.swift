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
  }
  
  private func setupYoutubeClient() {
    youtubeClient.getVideoWithIdentifier(youtubeID) { [weak self] video, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        print(error!)
        return
      }
      if let streamURLs = video?.streamURLs, let tempStreamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
        self.streamURL = tempStreamURL
        /*
         @property (nonatomic, readonly) NSString *identifier;
         /**
         *  The title of the video.
         */
         @property (nonatomic, readonly) NSString *title;
         /**
         *  The duration of the video in seconds.
         */
         @property (nonatomic, readonly) NSTimeInterval duration;
         /**
         *  A thumbnail URL for an image of small size, i.e. 120×90. May be nil.
         */
         @property (nonatomic, readonly, nullable) NSURL *thumbnailURL;
         /**
         *  A thumbnail URL for an image of small size, i.e. 120×90. May be nil.
         */
         @property (nonatomic, readonly, nullable) NSURL *smallThumbnailURL DEPRECATED_MSG_ATTRIBUTE("Renamed. Use `thumbnailURL` instead.");
         /**
         *  A thumbnail URL for an image of medium size, i.e. 320×180, 480×360 or 640×480. May be nil.
         */
         @property (nonatomic, readonly, nullable) NSURL *mediumThumbnailURL DEPRECATED_MSG_ATTRIBUTE("No longer available. Use `thumbnailURL` instead.");
         /**
         *  A thumbnail URL for an image of large size, i.e. 1'280×720 or 1'980×1'080. May be nil.
         */
         @property (nonatomic, readonly, nullable) NSURL *largeThumbnailURL DEPRECATED_MSG_ATTRIBUTE("No longer available. Use `thumbnailURL` instead.");
         
         /**
         *  A dictionary of video stream URLs.
         *
         *  The keys are the YouTube [itag](https://en.wikipedia.org/wiki/YouTube#Quality_and_formats) values as `NSNumber` objects. The values are the video URLs as `NSURL` objects. There is also the special `XCDYouTubeVideoQualityHTTPLiveStreaming` key for live videos.
         *
         *  You should not store the URLs for later use since they have a limited lifetime and are bound to an IP address.
         *
         *  @see XCDYouTubeVideoQuality
         *  @see expirationDate
         */
         #if __has_feature(objc_generics)
         @property (nonatomic, readonly) NSDictionary<id, NSURL *> *streamURLs;
         #else
         @property (nonatomic, readonly) NSDictionary *streamURLs;
         */
//        video.
//        self.updateRemoteCommandCenterData(songItem: self.playingItem!)
        self.setupRemoteCommandCenter()
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
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {   // 要放在main thread才能更新remote center UI, 延後一秒，等songItem 準備好
      //            DLog("CMTimeGetSeconds(songItem.currentTime()): \(CMTimeGetSeconds(songItem.currentTime()))")
//      let image = UIImage(
//      video.duration
//      video.curren
      
//      let artwork = MPMediaItemArtwork(image: resultImage)
//      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
//        MPMediaItemPropertyTitle: video.title,
//        MPMediaItemPropertyArtwork: artwork,
//        MPMediaItemPropertyPlaybackDuration: NSNumber(value: CMTimeGetSeconds(songItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: CMTimeGetSeconds(songItem.currentTime())),
//        MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1)
//      ]
      
    }
  }
}

struct YouTubeVideoQuality {
  static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
  static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
  static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}
