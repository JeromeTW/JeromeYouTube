//
//  JeromeNavigationBar.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/13.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class JeromeNavigationBar: UIView {
  
}

extension UIViewController {
  func addJeromeNavigationBar() {
    
  }
}

protocol HasJeromeNavigationBar: UIViewController {
  var topView: UIView! { get set }
  var statusView: UIView! { get set }
  var navagationView: UIView! { get set }
  var statusViewHeightConstraint: NSLayoutConstraint! { get set }
  var navagationViewHeightConstraint: NSLayoutConstraint! { get set }
  var observer: NSObjectProtocol? { get set }
  
  func setupSatusBarFrameChangedObserver()
  func removeSatusBarHeightChangedObserver()
  func updateTopView()
}

extension HasJeromeNavigationBar {
  func setupSatusBarFrameChangedObserver() {
    observer = NotificationCenter.default.addObserver(forName: UIApplication.willChangeStatusBarFrameNotification, object: nil, queue: nil) { [weak self] _ in
      DispatchQueue.main.async {
        guard let self = self else {
          return
        }
        self.updateTopView()
      }
    }
  }
  
  func updateTopView() {
    let statusHeight = UIApplication.shared.statusBarFrame.size.height
    statusViewHeightConstraint.constant = statusHeight
    if UIApplication.shared.statusBarOrientation.isPortrait {
      navagationViewHeightConstraint.constant = 44
    } else {
      navagationViewHeightConstraint.constant = 32
    }
  }
  
  func removeSatusBarHeightChangedObserver() {
    if let observer = observer {
      NotificationCenter.default.removeObserver(observer)
    }
  }
}
