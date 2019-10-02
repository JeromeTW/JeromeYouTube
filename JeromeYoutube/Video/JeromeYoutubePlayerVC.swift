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
  
  private var observer: NSObjectProtocol?
  override func viewDidLoad() {
    super.viewDidLoad()
    observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil, queue: nil) { _ in
      YoutubePlayer.shared.youtubePlayerVC = nil
    }
  }
  
  deinit {
    if let observer = observer {
      NotificationCenter.default.removeObserver(observer)
    }
    YoutubePlayer.shared.youtubePlayerVC = nil
    logger.log("\(self.className) deinit")
  }
}
