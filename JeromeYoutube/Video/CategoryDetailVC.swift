//
//  CategoryDetailVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/15.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData
import UIKit

class CategoryDetailVC: BaseViewController, Storyboarded, HasJeromeNavigationBar {
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var navagationView: UIView!
  @IBOutlet weak var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var navagationViewHeightConstraint: NSLayoutConstraint!
  
  var observer: NSObjectProtocol?
  
  var category: VideoCategory!
  var coredataConnect = CoreDataConnect()
  let youtubePlayer = YoutubePlayer.shared
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = category.name
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
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
  
  override func setupData() {
    super.setupData()
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  
  @IBAction func backBtnPressed(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UITableViewDataSource
extension CategoryDetailVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return category.videos?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = (tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableViewCell.className, for: indexPath) as? CategoryDetailTableViewCell)!
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CategoryDetailVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let video = category.videos?.object(at: indexPath.row) as? Video else {
      fatalError()
    }
    guard let categoryDetailTableViewCell = cell as? CategoryDetailTableViewCell else {
      fatalError()
    }
    categoryDetailTableViewCell.beforeReuse()
    categoryDetailTableViewCell.updateUI(by: video)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let video = category.videos?.object(at: indexPath.row) as? Video else {
      fatalError()
    }
    youtubePlayer.play(video: video)
    let videoPlayerViewController = JeromeYoutubePlayerVC(videoIdentifier: video.youtubeID)
    youtubePlayer.youtubePlayerVC = videoPlayerViewController
    present(videoPlayerViewController, animated: true) {
      videoPlayerViewController.moviePlayer.play()
    }
  }
}
