//
//  MiniPlayerView.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/11.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import AVKit

class MiniPlayerView: UIView {
    
  @IBOutlet weak var videoContainerView: UIView!
  @IBOutlet weak var songTitleLabel: UILabel!
  @IBOutlet weak var playPauseBtn: UIButton!
  @IBOutlet weak var closeBtn: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  weak var videoLayer: CALayer?
  
  var contentView: UIView?
  
  let jeromePlayer = JeromePlayer.shared
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }
  
  func xibSetup() {
    contentView = loadViewFromNib()
    // Use bounds not frame or it'll be offset
    contentView!.frame = bounds
    
    // Make the view stretch with containing view
    contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.backgroundColor = UIColor.clear
    
    songTitleLabel.text = ""
    //        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name(rawValue: kUpdateSimplePlayerUI), object: nil)
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(contentView!)
//    updateUI()
  }
  
  func loadViewFromNib() -> UIView! {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    return view
  }
  
  func updateUI(by video: Video, videoList: [Video]) {
    songTitleLabel.text = video.name
    if let videoLayer = videoLayer {
      videoLayer.removeFromSuperlayer()
    }
    
    if video.savePlace == 0 {
      imageView.isHidden = false
    } else {
      imageView.isHidden = true
    }
    let handler: YoutubePlayerIsRedayHandler = {
      [weak self] layer in
      guard let self = self else { return }
      self.videoLayer = layer
      self.videoContainerView.layer.addSublayer(layer)
      layer.frame = self.videoContainerView.bounds
    }
    jeromePlayer.play(video: video, videoList: videoList, youtubePlayerIsRedayHandler: handler)
    isHidden = false
  }
//
//  func updateUI() {
//    /// FIXME: 如果切換歌單太快會crash.
//    guard let playerController = playerHelper.returnExistPlayableObject() else { return }
//    updatePrevNextButtons()
//    updatePlayBtn()
//    if playerController is LocalPlayer {
//      let item = playerController.contentArray[playerController.currentIndex] as! MusicBean
//      updateData(image: item.musicCover, imageURL: nil, songName: item.musicName, albumName: item.albumTitle)
//    } else if playerController is JeromePlayer {
//      let item = playerController.contentArray[playerController.currentIndex] as! ContentItem
//      var thumbnailURL = ""
//      if item.thumbnailURL == "" {  // 我的音樂的ContentItem server沒有給縮圖，得自己抓
//        thumbnailURL = getYoutubeThumbnailURL(from: item.URL)
//      } else {  // 線上影音的ContentItem server有給縮圖，可以直接用
//        thumbnailURL = item.thumbnailURL
//      }
//      updateData(image: nil, imageURL: thumbnailURL, songName: item.name, albumName: nil)
//    } else if playerController is TXPlayer {
//      let item = playerController.contentArray[playerController.currentIndex] as! ContentItem
//      var thumbnailURL = ""
//      if item.thumbnailURL == "" {  // 我的音樂的ContentItem server沒有給縮圖，得自己抓
//        thumbnailURL = getTencentThumbnailURL(from: item.getTXID()!)
//      } else {  // 線上影音的ContentItem server有給縮圖，可以直接用
//        thumbnailURL = item.thumbnailURL
//      }
//      updateData(image: nil, imageURL: thumbnailURL, songName: item.name, albumName: nil)
//    }
//  }
//  func updateData(image: UIImage?, imageURL: String?, songName: String?, albumName: String?) {
//    if let image = image {
//      imageView.image = image
//    } else if let imageURL = imageURL, let tmpURL = URL(string: imageURL) {
//      let URLMD5Hex = MD5Hex(imageURL)
//      let imageResource = ImageResource(downloadURL: tmpURL, cacheKey: URLMD5Hex)
//      imageView.kf.indicatorType = .custom(indicator: MyIndicator() as Indicator)
//      imageView.kf.setImage(with: imageResource, placeholder: UNKNOWN_IMAGE, options: [.transition(.fade(0.2))])
//    }
//    if let songName = songName {
//      songLabel.text = songName
//    } else {
//      songLabel.text = LocStr(NO_SONG_NAME)
//    }
//    if let albumName = albumName {
//      albumLabel.isHidden = false
//      albumLabel.text = albumName
//    } else {
//      albumLabel.isHidden = true
//    }
//    if albumName == "" {
//      albumLabel.isHidden = true
//    }
//  }
//
//  func updatePrevNextButtons() {
//    guard let playerController = playerHelper.returnExistPlayableObject() else { return }
//    if playerController.currentIndex <= 0 {  // 第一首，不能按上一首
//      previousBtn.isEnabled = false
//    } else {
//      previousBtn.isEnabled = true
//    }
//    if playerController.currentIndex >= playerController.contentArray.count - 1 { // 如果為最後一首歌，當currentIndex == contentArray.count - 1 超出邊界時, 不能按下一首
//      nextBtn.isEnabled = false
//    } else {
//      nextBtn.isEnabled = true
//    }
//  }
  
  func updatePlayBtn() {
    if jeromePlayer.isPlaying {
      playPauseBtn.setImage(UIImage(systemName: "pause")!, for: .normal)
    } else {
      playPauseBtn.setImage(UIImage(systemName: "play")!, for: .normal)
    }
  }
  
  // MARK: - IBActions
  @IBAction func playPauseBtn(_ sender: UIButton) {
    if jeromePlayer.isPlaying {
      jeromePlayer.pause()
    } else {
      jeromePlayer.continuePlaying()
    }
    updatePlayBtn()
  }
  
  @IBAction func closeBtn(_ sender: UIButton) {
    jeromePlayer.resetPlayer()
    isHidden = true
  }
  
//  func lockChangeSongBtn() {
//    previousBtn.isEnabled = false
//    nextBtn.isEnabled = false
//  }
}

