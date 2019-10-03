// CategoryListVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import CoreData
import UIKit

class CategoryListVC: BaseViewController, Storyboarded, HasJeromeNavigationBar {
  @IBOutlet var topView: UIView!
  @IBOutlet var statusView: UIView!
  @IBOutlet var navagationView: UIView!
  @IBOutlet var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var navagationViewHeightConstraint: NSLayoutConstraint!

  weak var videoCoordinator: VideoCoordinator?
  var observer: NSObjectProtocol?

  let youtubePlayer = YoutubePlayer.shared

  @IBOutlet var titleLabel: UILabel! {
    didSet {
      titleLabel.text = "類型清單"
    }
  }

  private lazy var categoryFRC: NSFetchedResultsController<VideoCategory>! = {
    let frc = coredataConnect.getFRC(type: VideoCategory.self, sortDescriptors: [NSSortDescriptor(key: #keyPath(VideoCategory.order), ascending: false)])
    frc.delegate = self
    return frc
  }()

  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.tableFooterView = UIView()
      tableView.contentInset = UIEdgeInsets(top: CGFloat.statusAndNavigationTotalHeight - 1, left: 0, bottom: 0, right: 0)
      tableView.contentInsetAdjustmentBehavior = .never
    }
  }

  let viewContext = UIApplication.viewContext
  private var coredataConnect = CoreDataConnect()
  private var blockOperations = [BlockOperation]()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupData()
    setupSatusBarFrameChangedObserver()
    updateTopView()
  }

  func setupData() {
    tableView.dataSource = self
    tableView.delegate = self
  }

  deinit {
    removeSatusBarHeightChangedObserver()
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
        guard self.coredataConnect.isTheYoutubeIDExisted(youtubeID) == false else {
          self.showOKAlert("已經新增過此影片", message: nil, okTitle: "OK")
          return
        }

        let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), VideoCategory.undeineCatogoryName)
        guard let category = self.coredataConnect.retrieve(type: VideoCategory.self, predicate: predicate, sort: nil, limit: 1)?.first else {
          fatalError()
        }
        try self.coredataConnect.insert(type: Video.self, attributeInfo: [
          #keyPath(Video.id): self.coredataConnect.generateNewID(Video.self) as Any,
          #keyPath(Video.order): self.coredataConnect.generateNewOrder(Video.self) as Any,
          #keyPath(Video.youtubeID): youtubeID as Any,
          #keyPath(Video.category): category as Any,
        ])
        let videoPredicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
        guard let video = self.coredataConnect.retrieve(type: Video.self, predicate: videoPredicate, sort: nil, limit: 1)?.first else {
          return
        }
        self.youtubePlayer.video = video
        self.showOKAlert("成功新增影片", message: nil, okTitle: "OK")
      } catch {
        // TODO: Error Handling
        logger.log(error.localizedDescription, level: .error)
      }
    }
  }

  @IBAction func webBtnPressed(_: Any) {
    let customWebViewController = CustomWebVC(nibName: "CustomWebVC", bundle: nil)
    guard let tempURL = URL(string: "https://www.youtube.com/results?search_query=music") else {
      assertionFailure()
      return
    }
    customWebViewController.theURL = tempURL
    present(customWebViewController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource

extension CategoryListVC: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryFRC.sections?[section].numberOfObjects ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = (tableView.dequeueReusableCell(withIdentifier: CategoryListTableViewCell.className, for: indexPath) as? CategoryListTableViewCell)!
    return cell
  }
}

// MARK: - UITableViewDelegate

extension CategoryListVC: UITableViewDelegate {
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let category = categoryFRC.object(at: indexPath)
    guard let categoryListTableViewCell = cell as? CategoryListTableViewCell else {
      return
    }
    categoryListTableViewCell.updateUI(by: category)
  }

  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categoryFRC.object(at: indexPath)
    videoCoordinator?.videoCategoryDetail(category: category)
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryListVC: NSFetchedResultsControllerDelegate {
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
      let category = categoryFRC.object(at: indexPath!)
      let categoryListTableViewCell = tableView.cellForRow(at: indexPath!) as! CategoryListTableViewCell
      categoryListTableViewCell.updateUI(by: category)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .none)
      tableView.insertRows(at: [newIndexPath!], with: .none)
    @unknown default:
      fatalError()
    }
  }

  func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.performBatchUpdates({
      [weak self] in
      guard let self = self else {
        return
      }
      for operation in self.blockOperations {
        operation.start()
      }
    }) { _ in
      let lastRow = self.categoryFRC.sections!.first!.numberOfObjects - 1
      let indexPath = IndexPath(row: lastRow, section: 0)
      self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
}
