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
  
  func beforeReuse() {
    titleLabel.text = nil
    thumbnailImage.image = nil
  }
  
  func updateUI(by video: Video) {
    titleLabel.text = video.name
    if let urlString = video.thumbnailURL, let url = URL(string: urlString) {
      ImageLoader.shared.imageByURL(url) {
        [weak self] image, url in
        guard let self = self else {
          return
        }
        if let image = image {
          self.thumbnailImage.image = image
        }
      }
    }
  }
}
