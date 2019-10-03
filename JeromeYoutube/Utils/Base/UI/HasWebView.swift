//
//  HasWebView.swift
//  GP920_iOS
//
//  Created by Jerome.Hsieh2 on 2019/1/29.
//  Copyright © 2019 Daniel. All rights reserved.
//

import UIKit
import WebKit
import Reachability

protocol HasWebView: class {
  var webView: WKWebView! { get set }
  var webErrorViewContainer: UIView! { get set }
  var request: URLRequest! { get set }
  var titleLabel: UILabel! { get set }
//  func setTryAgainHandler(for segue: UIStoryboardSegue)
  func reloadIfPossible(shouldChangeTitle: Bool)
  func setWebErrorViewContainer(shouldHidden: Bool, shouldChangeTitle: Bool)
}

extension HasWebView {
//  func setTryAgainHandler(for segue: UIStoryboardSegue) {
//    let webErrorViewController = segue.destination as! WebErrorVC
//    webErrorViewController.tryAgainHandler = {
//      [weak self] in
//      guard let self = self else { return }
//      self.reloadIfPossible()
//    }
//  }

  func reloadIfPossible(shouldChangeTitle: Bool = false) {
    if Reachability()!.connection != .none {
      setWebErrorViewContainer(shouldHidden: true, shouldChangeTitle: shouldChangeTitle)
      if webView.url != nil {
        webView.reload()
      } else {
        webView.load(request)
      }
    } else {
      setWebErrorViewContainer(shouldHidden: false, shouldChangeTitle: shouldChangeTitle)
    }
  }

  func setWebErrorViewContainer(shouldHidden: Bool, shouldChangeTitle: Bool = false) {
    guard webErrorViewContainer != nil else { return }
    webErrorViewContainer.isHidden = shouldHidden
    if shouldHidden == false && shouldChangeTitle {
      titleLabel.text = "webViewError"
    }
  }
}
