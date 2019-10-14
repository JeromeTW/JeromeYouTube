// CustomWebVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/7.

import CoreData
import Reachability
import SnapKit
import UIKit
import WebKit

class CustomWebVC: UIViewController {
  @IBOutlet var mainView: UIView!
  @IBOutlet var titleLabel: UILabel! {
    didSet {
      titleLabel.text = theURL.absoluteString
    }
  }

  @IBOutlet var topView: UIView!
  @IBOutlet var navagationView: UIView!
  @IBOutlet var navagationViewHeightConstraint: NSLayoutConstraint!

  @IBOutlet var closeButton: UIButton!
  @IBOutlet var addButton: UIButton! // 自定義行為之後或許可以 。。。 icon 表示更多功能。
  @IBOutlet var nextPageButton: UIButton! {
    didSet {
      nextPageButton.isHidden = true
    }
  }

  @IBOutlet var backPageButton: UIButton! {
    didSet {
      backPageButton.isHidden = true
    }
  }

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

  private var coreDataConnect = CoreDataConnect()

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

  @IBAction func addButtonPressed(_: Any) {
    showAlertController(withTitle: "加入分類", message: "可將影片加入多個分類下，用‘#’分隔多個分類名", textFieldsData: [TextFieldData(text: nil, placeholder: "e.g:未分類#跑步#熱血")], cancelTitle: "取消", cancelHandler: nil, okTitle: "加入") { [weak self] textFields in
      guard let self = self else { return }
      guard let textField = textFields.first else { fatalError() }
      guard let text = textField.text, text.isEmpty == false, text.hasPrefix("#") == false else {
        // 格式不正確
        return
      }
      let categoryNames = text.components(separatedBy: "#")
      // 加入已存在的 Categories
      // TODO: 如果輸入不存在的分類直接新增缺少的分類。
      let predicate = NSPredicate(format: "%K IN %@", #keyPath(VideoCategory.name), categoryNames)
      guard let categories = self.coreDataConnect.retrieve(type: VideoCategory.self, predicate: predicate, sort: nil) else {
        fatalError()
      }
      guard let urlString = self.webView.url?.absoluteString else {
        fatalError()
      }
      
      do {
        let youtubeID = try YoutubeHelper.grabYoutubeIDBy(text: urlString).get()
        try YoutubeHelper.add(youtubeID, to: categories, in: self.coreDataConnect)

        self.showOKAlert("成功新增影片", message: nil, okTitle: "OK")
      } catch YoutubeHelperError.youtubeIDInvalid {
        logger.log("Youtube ID Invalid.", level: .error)
        self.showOKAlert("Youtube ID Invalid", message: "\(text) 不是合法的 YouTube ID", okTitle: "OK")
        // TODO: Error Handling
      } catch {
        logger.log(error.localizedDescription, level: .error)
      }
    }
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

  func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
    logger.log("webView didFail. Error: \(error.localizedDescription)", theOSLog: .customWebView)
  }

  func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
    logger.log("webView didFailProvisionalNavigation. Error: \(error.localizedDescription)", theOSLog: .customWebView)
  }

  func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    logger.log("webView decidePolicyFor", theOSLog: .customWebView)
    guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
      decisionHandler(.cancel)
      return
    }
    logger.log("httpResponse.statusCode: \(httpResponse.statusCode)", theOSLog: .customWebView)
    if httpResponse.statusCode != 200 {}
    decisionHandler(.allow)
  }
}
