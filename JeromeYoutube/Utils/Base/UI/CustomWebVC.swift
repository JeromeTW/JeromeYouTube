// CustomWebVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Reachability
import UIKit
import WebKit

class CustomWebVC: UIViewController {
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = theURL.absoluteString
    }
  }
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var navagationView: UIView!
  @IBOutlet weak var navagationViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var nextPageButton: UIButton!
  @IBOutlet weak var backPageButton: UIButton!
  
  @IBOutlet var navigationButtons: [UIButton]!
  
  var webView: WKWebView! {
    didSet {
      request = URLRequest(url: theURL)
      webView.contentMode = .scaleAspectFit
      webView.navigationDelegate = self
      webView.sizeToFit()
      mainView.addSubview(webView)

      let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
      swipeRight.direction = .right

      let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
      swipeLeft.direction = .left

      webView.addGestureRecognizer(swipeRight)
      webView.addGestureRecognizer(swipeLeft)

      guard Reachability()!.connection != .none else {
        return
      }
      webView.load(request)
    }
  }
  
  var request: URLRequest!
  var theURL: URL!

  override func loadView() {
    super.loadView()
    assert(theURL != nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView = WKWebView()
  }

  override func viewDidAppear(_: Bool) {
    super.viewDidAppear(true)
    webView.frame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height)
  }

  @objc func swipe(_ recognizer: UISwipeGestureRecognizer) {
    if recognizer.direction == .right {
      if webView.canGoBack {
        webView.goBack()
      }
    } else if recognizer.direction == .left {
      if webView.canGoForward {
        webView.goForward()
      }
    }
  }

  @IBAction func closeButtonAction(_: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func nextPageButtonAction(_: Any) {
    if webView.canGoForward {
      webView.goForward()
    }
  }

  @IBAction func backPageButtonAction(_: Any) {
    if webView.canGoBack {
      webView.goBack()
    }
  }
}

// MARK: - WKNavigationDelegate

extension CustomWebVC: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    let urlString = webView.url?.absoluteString
    logger.log("webView.url?.absoluteString: \(String(describing: urlString))", theOSLog: .customWebView)
  }

  func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {

    webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';", completionHandler: nil)

    backPageButton.imageView?.image = UIImage(named: webView.canGoBack ? "BackPageButton_On" : "BackPageButton_Off")
    nextPageButton.imageView?.image = UIImage(named: webView.canGoForward ? "NextPageButton_On" : "NextPageButton_Off")
  }

  func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
  }

  func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
  }

  func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
      decisionHandler(.cancel)
      return
    }
    logger.log("httpResponse.statusCode: \(httpResponse.statusCode)", theOSLog: .customWebView)
    if httpResponse.statusCode != 200 {
    }
    decisionHandler(.allow)
  }
}
