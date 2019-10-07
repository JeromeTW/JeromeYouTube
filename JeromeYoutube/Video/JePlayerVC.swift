//
//  JePlayerVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/7.
//  Copyright © 2019 jerome. All rights reserved.
//

import  UIKit
import AVKit

class JePlayerVC: AVPlayerViewController {
  
  var onDismiss: (() -> Void)?

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isBeingDismissed {
      onDismiss?()
    }
  }
}
