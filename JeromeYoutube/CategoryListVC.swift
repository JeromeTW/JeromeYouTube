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

class CategoryListVC: BaseViewController, Storyboarded {
  
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
  private var coredataConnect: CoreDataConnect!
  private let reuseIdentifier = "Cell"
  private var blockOperations = [BlockOperation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(viewContext != nil)
    setupData()
  }
  
  override func setupData() {
    super.setupData()
    setUpCoreData()
//    categoryFRC = coredataConnect.getFRC(type: VideoCategory.self, sortDescriptors: [NSSortDescriptor(key: #keyPath(VideoCategory.order), ascending: false)])
//    categoryFRC.delegate = self
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  private func setUpCoreData() {
    coredataConnect = CoreDataConnect(context: viewContext)
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
        self.showOKAlert("成功新增影片", message: nil, okTitle: "OK")
      } catch {
        // TODO: Error Handling
        printLog(error.localizedDescription, level: .error)
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryListVC: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    if type == .insert {
      blockOperations.append(BlockOperation(block: {
        [weak self] in
        guard let self = self else {
          return
        }
        self.tableView.insertRows(at: [newIndexPath!], with: .none)
      }))
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
