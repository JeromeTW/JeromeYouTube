// CategoryDetailVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import CoreData
import Reachability
import UIKit

class CategoryDetailVC: BaseViewController, Storyboarded, HasJeromeNavigationBar {
  @IBOutlet var topView: UIView!
  @IBOutlet var statusView: UIView!
  @IBOutlet var navagationView: UIView!
  @IBOutlet var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var navagationViewHeightConstraint: NSLayoutConstraint!

  weak var videoCoordinator: VideoCoordinator?
  var observer: NSObjectProtocol?

  var category: VideoCategory!
  var coredataConnect = CoreDataConnect()
  let youtubePlayer = YoutubePlayer.shared

  @IBOutlet var titleLabel: UILabel! {
    didSet {
      titleLabel.text = category.name
    }
  }

  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.tableFooterView = UIView()
      tableView.contentInset = UIEdgeInsets(top: CGFloat.statusAndNavigationTotalHeight - 1, left: 0, bottom: 0, right: 0)
      tableView.contentInsetAdjustmentBehavior = .never
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    assert(category != nil)
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

  @IBAction func backBtnPressed(_: Any) {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UITableViewDataSource

extension CategoryDetailVC: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return category.videos?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = (tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableViewCell.className, for: indexPath) as? CategoryDetailTableViewCell)!
    return cell
  }
}

// MARK: - UITableViewDelegate

extension CategoryDetailVC: UITableViewDelegate {
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let video = category.videos?.object(at: indexPath.row) as? Video else {
      fatalError()
    }
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
    guard let video = category.videos?.object(at: indexPath.row) as? Video else {
      fatalError()
    }
    youtubePlayer.play(video: video) { [weak self] playerVC in
      guard let self = self else { return }
      self.present(playerVC, animated: true) {
        playerVC.player?.play()
      }
    }
  }
}
