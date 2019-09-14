//
//  MusicListVC.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/12.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData
import UIKit
import SafariServices

class MusicListVC: BaseViewController, Storyboarded {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var viewContext: NSManagedObjectContext!
  
  private var coredataConnect: CoreDataConnect!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(viewContext != nil)
    setUpCoreData()
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
      printLog("Text: \(text)")
      // Grab Text
      
      guard self.coredataConnect.insert(type: Video.self, attributeInfo: [
        #keyPath(Video.id): self.coredataConnect.generateNewID(Video.self) as Any,
        #keyPath(Video.order): self.coredataConnect.generateNewOrder(Video.self) as Any,
        #keyPath(Video.youtubeID): text as Any
        ]) else {
          fatalError()
      }
    }
  }
  
  @IBAction func webBtnPressed(_ sender: Any) {
    let safariVC = SFSafariViewController(url: URL(string: "https://www.youtube.com/results?search_query=music")!)
    present(safariVC, animated: true, completion: nil)
  }
}
