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
  @IBOutlet weak var addButton: UIButton! // 自定義行為之後或許可以 。。。 icon 表示更多功能。
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
  
  @IBAction func addButtonPressed(_ sender: Any) {
    let alert = AlertControllerWithPicker(title: "Title", message: "Message", preferredStyle: .actionSheet)
    alert.choices = ["1", "2", "3"]
    alert.didSelectedHandler = {
      string in
      print(string)
    }
    
    let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
    let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
    alert.view.addConstraints([height, width])
    
    present(alert, animated: true)
  }
}

// MARK: - WKNavigationDelegate

extension CustomWebVC: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    let urlString = webView.url?.absoluteString
    logger.log("webView didStartProvisionalNavigation url: \(String(describing: urlString))", theOSLog: .customWebView)
    titleLabel.text = urlString
  }

  func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
    logger.log("webView didFinish", theOSLog: .customWebView)
    backPageButton.isHidden = !webView.canGoBack
    nextPageButton.isHidden = !webView.canGoForward
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    logger.log("webView didFail. Error: \(error.localizedDescription)", theOSLog: .customWebView)
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    logger.log("webView didFailProvisionalNavigation. Error: \(error.localizedDescription)", theOSLog: .customWebView)
  }

  func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    logger.log("webView decidePolicyFor", theOSLog: .customWebView)
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
