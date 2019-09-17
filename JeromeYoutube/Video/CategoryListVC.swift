//
//  CategoryListVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/12.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData
import UIKit
import SafariServices

class CategoryListVC: BaseViewController, Storyboarded, HasJeromeNavigationBar {
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var navagationView: UIView!
  @IBOutlet weak var statusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var navagationViewHeightConstraint: NSLayoutConstraint!
  
  var observer: NSObjectProtocol?
  
  let youtubePlayer = YoutubePlayer.shared
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = "類型清單"
    }
  }
  
  private lazy var categoryFRC: NSFetchedResultsController<VideoCategory>! = {
    let frc = coredataConnect.getFRC(type: VideoCategory.self, sortDescriptors: [NSSortDescriptor(key: #keyPath(VideoCategory.order), ascending: false)])
    frc.delegate = self
    return frc
  }()
  
  @IBOutlet weak var tableView: UITableView!
  var viewContext: NSManagedObjectContext!
  private var coredataConnect = CoreDataConnect()
  private var blockOperations = [BlockOperation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(viewContext != nil)
    setupData()
    setupSatusBarFrameChangedObserver()
    updateTopView()
  }
  
  override func setupData() {
    super.setupData()
    tableView.tableFooterView = UIView()
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  deinit {
    removeSatusBarHeightChangedObserver()
  }
  
  @IBAction func addBtnPressed(_ sender: Any) {
    showAlertController(withTitle: "添加影片", message: "請輸入 ID 或是網址:", textFieldsData: [TextFieldData(text: nil, placeholder: "e.g: 6v2L2UGZJAM or https://www.youtube.com/watch?v=XULUBg_ZcAU")], cancelTitle: "取消", cancelHandler: nil, okTitle: "新增") { [weak self] textFields in
      guard let self = self else {
        return
      }
      guard let textField = textFields.first, let text = textField.text else {
        fatalError()
      }
      // Grab Text
      do {
        let youtubeID = try  YoutubeHelper.grabYoutubeIDBy(text: text).get()
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
          #keyPath(Video.category): category as Any
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
  
  @IBAction func webBtnPressed(_ sender: Any) {
    // TODO: Change to WKWebView, SFSafariViewController can not get its url.
    let safariVC = SFSafariViewController(url: URL(string: "https://www.youtube.com/results?search_query=music")!)
    present(safariVC, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension CategoryListVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryFRC.sections?[section].numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = (tableView.dequeueReusableCell(withIdentifier: CategoryListTableViewCell.className, for: indexPath) as? CategoryListTableViewCell)!
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CategoryListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let category = categoryFRC.object(at: indexPath)
    guard let categoryListTableViewCell = cell as? CategoryListTableViewCell else {
      return
    }
    categoryListTableViewCell.updateUI(by: category)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categoryFRC.object(at: indexPath)
    let storyboard = UIStoryboard(name: "CategoryListTab", bundle: Bundle.main)
    let categoryDetailVC = CategoryDetailVC.instantiate(storyboard: storyboard)
    categoryDetailVC.category = category
    categoryDetailVC.coredataConnect = coredataConnect
    navigationController?.pushViewController(categoryDetailVC, animated: true)
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryListVC: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
      let categoryListTableViewCell = self.tableView.cellForRow(at: indexPath!) as! CategoryListTableViewCell
      categoryListTableViewCell.updateUI(by: category)
    case .move:
      self.tableView.deleteRows(at: [indexPath!], with: .none)
      self.tableView.insertRows(at: [newIndexPath!], with: .none)
    @unknown default:
      fatalError()
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.performBatchUpdates({
      [weak self] in
      guard let self = self else {
        return
      }
      for operation in self.blockOperations {
        operation.start()
      }
    }) { (complete) in
      let lastRow = self.categoryFRC.sections!.first!.numberOfObjects - 1
      let indexPath = IndexPath(row: lastRow, section: 0)
      self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
}
