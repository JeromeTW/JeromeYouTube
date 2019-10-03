// CustomWebViewController.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Reachability
// import SVProgressHUD
import UIKit
import WebKit

class CustomWebViewController: UIViewController, HasWebView {
  @IBOutlet var mainView: UIView!
  @IBOutlet var titleView: UIView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var controlBarView: UIView!
  @IBOutlet var maskView: UIView!
  @IBOutlet var refreshButton: UIButton!
  @IBOutlet var nextPageButton: UIButton!
  @IBOutlet var backPageButton: UIButton!
  var webView: WKWebView!
  var webErrorViewContainer: UIView!
  var request: URLRequest!
  var theURL: URL!
  var customTitle = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    assert(theURL != nil)
    titleView.layer.shadowColor = UIColor.black.cgColor
    titleView.layer.shadowOpacity = 0.4
    titleView.layer.shadowOffset = CGSize.zero
    titleView.layer.shadowRadius = 5.0

//    controlBarView.backgroundColor = UIColor(.enterpriseDarkblack)

    titleLabel.text = customTitle
//    titleLabel.textColor = UIColor(.enterpriseBlue)

    request = URLRequest(url: theURL)
    webView = WKWebView()
    webView.contentMode = .scaleAspectFit
    webView.scrollView.alwaysBounceVertical = false
    webView.navigationDelegate = self
    webView.scrollView.delegate = self
    webView.sizeToFit()
    maskView.addSubview(webView)

    let webErrorVC = WebErrorVC(nibName: "webErrorVC", bundle: nil)
    webErrorViewContainer = UIView()
    webErrorViewContainer.frame = maskView.bounds
    maskView.addSubview(webErrorViewContainer)

    webErrorVC.view.frame = webErrorViewContainer.bounds
    webErrorViewContainer.addSubview(webErrorVC.view)
    webErrorVC.tryAgainHandler = {
      [weak self] in
      guard let self = self else { return }
      self.reloadIfPossible()
    }

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
//    SVProgressHUD.dismiss()

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

extension CustomWebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    let urlString = webView.url?.absoluteString
    logger.log("webView.url?.absoluteString: \(urlString)")
//    SVProgressHUD.show(withStatus: "webLoading".localized())
  }

  func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
//    SVProgressHUD.dismiss()

    webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';", completionHandler: nil)

    backPageButton.imageView?.image = UIImage(named: webView.canGoBack ? "BackPageButton_On" : "BackPageButton_Off")
    nextPageButton.imageView?.image = UIImage(named: webView.canGoForward ? "NextPageButton_On" : "NextPageButton_Off")
  }

  func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
//    SVProgressHUD.dismiss()
    setWebErrorViewContainer(shouldHidden: false)
  }

  func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
//    SVProgressHUD.dismiss()
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

extension CustomWebViewController: UIScrollViewDelegate {
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
