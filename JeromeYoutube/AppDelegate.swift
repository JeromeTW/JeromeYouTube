// AppDelegate.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/6.

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  lazy var jeromePlayer = JeromePlayer.shared
  lazy var logTextView: LogTextView = {
    let logTextView = LogTextView(frame: .zero)
    logTextView.layer.zPosition = .greatestFiniteMagnitude
    return logTextView
  }()

  lazy var persistentContainerManager = PersistentContainerManager.shared

  func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UserDefaults.standard.setAPPVersionAndHistory()
    setupLogConfigure()
    logger.log("NSHomeDirectory:\(NSHomeDirectory())", level: .debug)
    BundleManager.addCategoriesAndVideosToDBIfNeeded()
    #if TEST
      print("🌘 TEST")
      setupWindow(rootViewController: UIViewController())
      return true
    #else
      print("🌘 NOT TEST")
      setupWindow(rootViewController: MainTabBarController())
      setupLogTextView()
      do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try AVAudioSession.sharedInstance().setActive(true)

        //! ! IMPORTANT !!
        /*
         If you're using 3rd party libraries to play sound or generate sound you should
         set sample rate manually here.
         Otherwise you wont be able to hear any sound when you lock screen
         */
        try AVAudioSession.sharedInstance().setPreferredSampleRate(4096)
      } catch {
        logger.log(error)
      }
      // This will enable to show nowplaying controls on lock screen
      application.beginReceivingRemoteControlEvents()
      return true
    #endif
  }

  // MARK: - Private method

  private func setupWindow(rootViewController: UIViewController) {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else { fatalError() }
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
  }

  func applicationDidBecomeActive(_: UIApplication) {
    jeromePlayer.setVideoTrack(true)
  }

  func applicationDidEnterBackground(_: UIApplication) {
    jeromePlayer.setVideoTrack(false)
  }

  func applicationWillTerminate(_: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    do {
      try persistentContainerManager.persistentContainer.saveContext()
    } catch {
      logger.log("Error:\(error.localizedDescription)", level: .error)
    }
  }
}

// MARK: - Log

extension AppDelegate {
  private func setupLogConfigure() {
    logger.configure([.fault, .error, .debug, .info, .defaultLevel], shouldShow: false, shouldCache: true)
  }

  private func setupLogTextView() {
    #if DEBUG
      guard let window = window else { return }
      guard logger.shouldShow else { return }

      if #available(iOS 11.0, *) {
        window.addSubview(logTextView, constraints: [
          UIView.anchorConstraintEqual(from: \UIView.topAnchor, to: \UIView.safeAreaLayoutGuide.topAnchor, constant: .defaultMargin),
          UIView.anchorConstraintEqual(from: \UIView.leadingAnchor, to: \UIView.safeAreaLayoutGuide.leadingAnchor, constant: .defaultMargin),
          UIView.anchorConstraintEqual(from: \UIView.bottomAnchor, to: \UIView.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
          UIView.anchorConstraintEqual(from: \UIView.trailingAnchor, to: \UIView.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue),
        ])
      } else {
        window.addSubview(logTextView, constraints: [
          UIView.anchorConstraintEqual(with: \UIView.topAnchor, constant: .defaultMargin),
          UIView.anchorConstraintEqual(with: \UIView.leadingAnchor, constant: .defaultMargin),
          UIView.anchorConstraintEqual(with: \UIView.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
          UIView.anchorConstraintEqual(with: \UIView.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue),
        ])
      }
    #endif
  }
}
