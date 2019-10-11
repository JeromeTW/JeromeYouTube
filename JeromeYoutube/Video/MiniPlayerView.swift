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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func xibSetup() {
    contentView = loadViewFromNib()
    // Use bounds not frame or it'll be offset
    contentView!.frame = bounds
    
    // Make the view stretch with containing view
    contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.backgroundColor = UIColor.clear
    
    songTitleLabel.text = ""
    addSubview(contentView!)
    NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(notification:)), name: NSNotification.Name(rawValue: "playbackFinished"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(youtubePlayerIsRedayHandler(notification:)), name: NSNotification.Name(rawValue: "youtubePlayerIsRedayHandler"), object: nil)
  }
  
  @objc func playbackFinished(notification: Notification) {
    let userInfo = notification.userInfo
    if let video = userInfo?["video"] as? Video {
      updateUI(by: video)
    }
  }
  
  @objc func youtubePlayerIsRedayHandler(notification: Notification) {
    let userInfo = notification.userInfo
    if let layer = userInfo?["layer"] as? AVPlayerLayer {
      self.videoLayer = layer
      self.videoContainerView.layer.addSublayer(layer)
      layer.frame = self.videoContainerView.bounds
    }
  }
  
  func loadViewFromNib() -> UIView! {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    return view
  }
  
  func updateUI(by video: Video) {
    songTitleLabel.text = video.name
    if let videoLayer = videoLayer {
      videoLayer.removeFromSuperlayer()
    }
    
    if video.savePlace == 0 {
      imageView.isHidden = false
    } else {
      imageView.isHidden = true
    }
    isHidden = false
  }
  
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
}

