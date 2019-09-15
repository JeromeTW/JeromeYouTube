//
//  CategoryDetailVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/15.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData
import UIKit

class CategoryDetailVC: BaseViewController, Storyboarded {
  var category: VideoCategory!
  var coredataConnect: CoreDataConnect!
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = category.name
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(category != nil && coredataConnect != nil)
    setupData()
  }
  
  override func setupData() {
    super.setupData()
    tableView.tableFooterView = UIView()
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
    categoryDetailTableViewCell.updateUI(by: video)
  }
}
