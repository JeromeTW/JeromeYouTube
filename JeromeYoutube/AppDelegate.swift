//
//  AppDelegate.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/10.
//  Copyright © 2019 jerome. All rights reserved.
//

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var logTextView: LogTextView = {
    let logTextView = LogTextView(frame: .zero)
    logTextView.layer.zPosition = .greatestFiniteMagnitude
    return logTextView
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do
    {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true)
      
      //!! IMPORTANT !!
      /*
       If you're using 3rd party libraries to play sound or generate sound you should
       set sample rate manually here.
       Otherwise you wont be able to hear any sound when you lock screen
       */
      try AVAudioSession.sharedInstance().setPreferredSampleRate(4096)
    }
    catch
    {
      print(error)
    }
    // This will enable to show nowplaying controls on lock screen
    application.beginReceivingRemoteControlEvents()
    UserDefaults.standard.setAPPVersionAndHistory()
    setupLogConfigure()
    setupLogTextView()
    printLog("NSHomeDirectory:\(NSHomeDirectory())", level: .debug)
    setupWindow()
    return true
  }

  // MARK: - Private method
  private func setupWindow() {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else { fatalError() }
    let tabBarController = UITabBarController()
    let storyboard = UIStoryboard(name: "MusicListTab", bundle: Bundle.main)
    let musicListVC = MusicListVC.instantiate(storyboard: storyboard)
    let musicListViewControllerInfo = ViewControllerInfo(hasNavigation: true, viewController: musicListVC, tabBarItem: UITabBarItem(title: "List", image: nil, selectedImage: nil))
    tabBarController.setupViewControllers([musicListViewControllerInfo])
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
  }
}

// MARK: - Log
extension AppDelegate {
  private func setupLogConfigure() {
    LogLevelConfigurator.shared.configure([.error, .warning, .debug, .info], shouldShow: false, shouldCache: false)
  }
  
  private func setupLogTextView() {
    #if DEBUG
    guard let window = window else { return }
    
    if #available(iOS 11.0, *) {
      window.addSubview(logTextView, constraints: [
        UIView.anchorConstraintEqual(from: \UIView.topAnchor, to: \UIView.safeAreaLayoutGuide.topAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(from: \UIView.leadingAnchor, to: \UIView.safeAreaLayoutGuide.leadingAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(from: \UIView.bottomAnchor, to: \UIView.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
        UIView.anchorConstraintEqual(from: \UIView.trailingAnchor, to: \UIView.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue)
        ])
    } else {
      window.addSubview(logTextView, constraints: [
        UIView.anchorConstraintEqual(with: \UIView.topAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(with: \UIView.leadingAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(with: \UIView.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
        UIView.anchorConstraintEqual(with: \UIView.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue)
        ])
    }
    #endif
  }
}
