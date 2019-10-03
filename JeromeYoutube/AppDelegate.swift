// AppDelegate.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/2.

import AVFoundation
import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  lazy var youtubePlayer = YoutubePlayer.shared
  lazy var logTextView: LogTextView = {
    let logTextView = LogTextView(frame: .zero)
    logTextView.layer.zPosition = .greatestFiniteMagnitude
    return logTextView
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
    UserDefaults.standard.setAPPVersionAndHistory()
    setupLogConfigure()
    logger.log("NSHomeDirectory:\(NSHomeDirectory())", level: .debug)
    setupWindow()
    setupLogTextView()
    setupCoreDataDB()
    return true
  }

  // MARK: - Private method

  private func setupWindow() {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else { fatalError() }
    window.rootViewController = MainTabBarController()
    window.makeKeyAndVisible()
  }

  func applicationDidBecomeActive(_: UIApplication) {
    youtubePlayer.setVideoTrack(true)
  }

  func applicationDidEnterBackground(_: UIApplication) {
    youtubePlayer.setVideoTrack(false)
  }

  func applicationWillTerminate(_: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    do {
      try persistentContainer.saveContext()
    } catch {
      logger.log("Error:\(error.localizedDescription)", level: .error)
    }
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "Video")
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  lazy var viewContext: NSManagedObjectContext = {
    persistentContainer.viewContext
  }()

  func setupCoreDataDB() {
    // 如果沒有未分類，則建立一個未分類。
    CoreDataConnect().insertFirstVideoCategoryIfNeeded()
  }
}

// MARK: - Log

extension AppDelegate {
  private func setupLogConfigure() {
    logger.configure([.error, .warning, .debug, .info], shouldShow: false, shouldCache: true)
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

extension UIApplication {
  static var viewContext: NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.viewContext
  }
}
