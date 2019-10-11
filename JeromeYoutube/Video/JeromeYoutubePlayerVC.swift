// JeromeYoutubePlayerVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit
import XCDYouTubeKit

class JeromeYoutubePlayerVC: XCDYouTubeVideoPlayerViewController {
  private var observer: NSObjectProtocol?
  override func viewDidLoad() {
    super.viewDidLoad()
    observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil, queue: nil) { _ in
      JeromePlayer.shared.youtubePlayerVC = nil
    }
  }

  deinit {
    if let observer = observer {
      NotificationCenter.default.removeObserver(observer)
    }
    JeromePlayer.shared.youtubePlayerVC = nil
    logger.log("\(self.className) deinit")
  }
}
