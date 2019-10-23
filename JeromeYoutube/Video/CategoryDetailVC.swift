// CategoryDetailVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import CoreData
import Reachability
import UIKit
import AVKit

class CategoryDetailVC: BaseViewController, Storyboarded, HasJeromeNavigationBar {
  @IBOutlet var topView: UIView!
  @IBOutlet var statusView: UIView!
  @IBOutlet var navagationView: UIView!
  @IBOutlet var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var navagationViewHeightConstraint: NSLayoutConstraint!

  weak var videoCoordinator: VideoCoordinator?
  var observer: NSObjectProtocol?

  var category: VideoCategory!
  private lazy var videoFRC: NSFetchedResultsController<Video>! = {
    let predicate = NSPredicate(format: "ANY categories.name == %@", category.name!)
    let frc = coreDataConnect.getFRC(type: Video.self, predicate: predicate, sortDescriptors: [NSSortDescriptor(key: #keyPath(Video.id), ascending: true)])
    frc.delegate = self
    return frc
  }()
  
  private var videos = [Video]()
  
  var coreDataConnect = CoreDataConnect()
  private var blockOperations = [BlockOperation]()
  let jeromePlayer = JeromePlayer.shared

  @IBOutlet var titleLabel: UILabel! {
    didSet {
      titleLabel.text = category.name
    }
  }

  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: MiniPlayerView.viewHeight))
      tableView.contentInsetAdjustmentBehavior = .never
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    assert(category != nil)
    updateVideos()
    setupData()
    setupSatusBarFrameChangedObserver()
    updateTopView()
  }
  
  deinit {
    removeSatusBarHeightChangedObserver()
  }

  func setupData() {
    tableView.dataSource = self
    tableView.delegate = self
  }

  private func updateVideos() {
    videos = videoFRC.fetchedObjects ?? []
    if let videoIDOrders = category.videoIDOrders {
      // 按 videoIDOrders 排序
      videos = VideoSorter.sortVideos(videos, videoIDOrders: videoIDOrders)
    } else {
      // 一開始創建的 Category 都沒有 videoIDOrders，要進到 DetailVC 才有
      // Videos 不用另外排序了
      let newOrders = videos.map { (video) -> Int in
        return Int(exactly: video.id)!
      }
      coreDataConnect.setCategoryVideoOrders(category.name!, videoOrders: newOrders)
    }
  }
  
  @IBAction func backBtnPressed(_: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func addBtnPressed(_: Any) {
    showAlertController(withTitle: "添加影片", message: "請輸入 ID 或是網址:", textFieldsData: [TextFieldData(text: nil, placeholder: "e.g: 6v2L2UGZJAM or https://www.youtube.com/watch?v=XULUBg_ZcAU")], cancelTitle: "取消", cancelHandler: nil, okTitle: "新增") { [weak self] textFields in
      guard let self = self else {
        return
      }
      guard let textField = textFields.first, let text = textField.text else {
        fatalError()
      }
      // Grab Text
      do {
        let youtubeID = try YoutubeHelper.grabYoutubeIDBy(text: text).get()
        try YoutubeHelper.add(youtubeID, to: [self.category], in: self.coreDataConnect)

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

// MARK: - UITableViewDataSource

extension CategoryDetailVC: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = (tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableViewCell.className, for: indexPath) as? CategoryDetailTableViewCell)!
    return cell
  }
}

// MARK: - UITableViewDelegate

extension CategoryDetailVC: UITableViewDelegate {
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let video = videos[indexPath.row]
    guard let categoryDetailTableViewCell = cell as? CategoryDetailTableViewCell else {
      fatalError()
    }
    categoryDetailTableViewCell.beforeReuse()
    categoryDetailTableViewCell.updateUI(by: video)
  }

  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard Reachability()!.connection != .none else {
      showOKAlert("無法連上網路", message: "請先檢查您的網路狀態", okTitle: "OK")
      return
    }
    guard let videos = category.videos?.array as? [Video] else {
      fatalError()
    }
    let video = videos[indexPath.row]
    guard let mainTabBarController = tabBarController as? MainTabBarController else {
      fatalError()
    }
    
    let index = indexPath.row
    let beforeVideos = Array(videos[0..<index])
    let afterVideos = Array(videos[index..<videos.count])
    let newVideoList = afterVideos + beforeVideos
    
    mainTabBarController.miniPlayerView.updateUI(by: video)
    jeromePlayer.play(video: video, videoList: newVideoList, index: 0)
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryDetailVC: NSFetchedResultsControllerDelegate {
  func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      blockOperations.append(BlockOperation(block: {
        [weak self] in
        guard let self = self else {
          return
        }
        self.tableView.insertRows(at: [newIndexPath!], with: .none)
      }))
    case .delete:
      blockOperations.append(BlockOperation(block: {
        [weak self] in
        guard let self = self else {
          return
        }
        self.tableView.deleteRows(at: [indexPath!], with: .none)
      }))
    case .update:
      if let categoryDetailTableViewCell = tableView.cellForRow(at: indexPath!) as? CategoryDetailTableViewCell {
        guard let video = category.videos?.object(at: indexPath!.row) as? Video else {
          fatalError()
        }
        categoryDetailTableViewCell.beforeReuse()
        categoryDetailTableViewCell.updateUI(by: video)
      }
      
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .none)
      tableView.insertRows(at: [newIndexPath!], with: .none)
    @unknown default:
      fatalError()
    }
  }

  func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
    updateVideos()
    tableView.performBatchUpdates({
      [weak self] in
      guard let self = self else {
        return
      }
      for operation in self.blockOperations {
        operation.start()
      }
    }) { _ in
      let lastRow = self.videos.count - 1
      let indexPath = IndexPath(row: lastRow, section: 0)
      self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
}
