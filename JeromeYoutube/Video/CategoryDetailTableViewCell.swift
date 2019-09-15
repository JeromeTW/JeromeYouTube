//
//  CategoryDetailTableViewCell.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/15.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class CategoryDetailTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var thumbnailImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func updateUI(by video: Video) {
    titleLabel.text = video.name
//    thumbnailImage.image = UIImage(
  }
  
}
