// CategoryDetailTableViewCell.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit

class CategoryDetailTableViewCell: UITableViewCell {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var thumbnailImage: UIImageView!

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
      ImageLoader.shared.imageByURL(url) { [weak self] image, _ in
        guard let self = self else {
          return
        }
        if let image = image {
          self.thumbnailImage.image = image
        }
      }
    } else {
      self.thumbnailImage.image = UIImage(systemName: "photo")!
    }
  }
}
