// HasWebView.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Reachability
import UIKit
import WebKit

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
    if shouldHidden == false, shouldChangeTitle {
      titleLabel.text = "webViewError"
    }
  }
}
