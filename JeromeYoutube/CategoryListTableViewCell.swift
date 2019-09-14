//
//  CategoryListTableViewCell.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/14.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class CategoryListTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func updateUI(by category: VideoCategory) {
    titleLabel.text = category.name
    subTitleLabel.text = "\(category.videos!.count)" + "個影片"
  }
  
}
