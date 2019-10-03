// CustomWebVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Reachability
import UIKit
import WebKit

class CustomWebVC: UIViewController, HasWebView, HasJeromeNavigationBar {
  @IBOutlet var mainView: UIView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var closeButton: UIButton!
  @IBOutlet var controlBarView: UIView!
  @IBOutlet var topView: UIView!
  @IBOutlet var statusView: UIView!
  @IBOutlet var navagationView: UIView!
  @IBOutlet var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var navagationViewHeightConstraint: NSLayoutConstraint!
  var observer: NSObjectProtocol?
  
  @IBOutlet var refreshButton: UIButton!
  @IBOutlet var nextPageButton: UIButton!
  @IBOutlet var backPageButton: UIButton!
  var webView: WKWebView!
  var webErrorViewContainer: UIView!
  var request: URLRequest!
  var theURL: URL!

  override func viewDidLoad() {
    super.viewDidLoad()
    assert(theURL != nil)
    setupSatusBarFrameChangedObserver()
    statusViewHeightConstraint.constant = 0
    titleLabel.text = theURL.absoluteString

    request = URLRequest(url: theURL)
    webView = WKWebView()
    webView.contentMode = .scaleAspectFit
    webView.scrollView.alwaysBounceVertical = false
    webView.navigationDelegate = self
    webView.scrollView.delegate = self
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

  override func viewDidAppear(_: Bool) {
    super.viewDidAppear(true)
    webView.frame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height)
  }

  override func viewWillAppear(_: Bool) {
    super.viewWillAppear(true)
    reloadIfPossible()

    let cookieJar = HTTPCookieStorage.shared
    for cookie in cookieJar.cookies! {
      if cookie.name.contains("zendesk") {
        cookieJar.deleteCookie(cookie)
      }
    }
  }
  
  deinit {
    removeSatusBarHeightChangedObserver()
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

    /*
     IOS920-1284: The older SDK use assign instead of weak,
     it turns out that UIViewController is deallocated before the UITableView,
     so UITableView may send message to its delegate which is deallocated, that causes the crash.
     */

    webView.scrollView.delegate = nil
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

  @IBAction func refreshButtonAction(_: Any) {
    reloadIfPossible()
  }
}

// MARK: - WKNavigationDelegate

extension CustomWebVC: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    let urlString = webView.url?.absoluteString
    logger.log("webView.url?.absoluteString: \(urlString)")
  }

  func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {

    webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';", completionHandler: nil)

    backPageButton.imageView?.image = UIImage(named: webView.canGoBack ? "BackPageButton_On" : "BackPageButton_Off")
    nextPageButton.imageView?.image = UIImage(named: webView.canGoForward ? "NextPageButton_On" : "NextPageButton_Off")
  }

  func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
    setWebErrorViewContainer(shouldHidden: false)
  }

  func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
    setWebErrorViewContainer(shouldHidden: false)
  }

  func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
      decisionHandler(.cancel)
      return
    }
    logger.log("httpResponse.statusCode: \(httpResponse.statusCode)")
    if httpResponse.statusCode != 200 {
      setWebErrorViewContainer(shouldHidden: false)
    }
    decisionHandler(.allow)
  }
}

// MARK: - UIScrollViewDelegate

extension CustomWebVC: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_: UIScrollView) {
    controlBarView.isHidden = true
  }

  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if targetContentOffset.pointee.y < scrollView.contentOffset.y {
      controlBarView.isHidden = false
    } else {
      // it's going down
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let height = scrollView.frame.size.height
    let contentYoffset = scrollView.contentOffset.y
    let distanceFromBottom = scrollView.contentSize.height - contentYoffset
    if distanceFromBottom < height {
      controlBarView.isHidden = false
    }
  }
}
