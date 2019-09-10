//
//  ViewController.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/10.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func buttonPressed(_ sender: Any) {
    let videoPlayerViewController = JeromeYoutubePlayerVC(videoIdentifier: "6v2L2UGZJAM")
    present(videoPlayerViewController, animated: true) {
      videoPlayerViewController.moviePlayer.play()
    }
  }
}
