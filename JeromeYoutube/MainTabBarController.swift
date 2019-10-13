// MainTabBarController.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit
import SnapKit

struct UITabBarItemInfo {
  var title: String?
  var image: UIImage?
  var selectedImage: UIImage?
}

class MainTabBarController: UITabBarController {
  let main = VideoCoordinator()
  let tabBarItemInfos: [UITabBarItemInfo] = [UITabBarItemInfo(title: "List", image: nil, selectedImage: nil)]
  var miniPlayerView = MiniPlayerView(frame: CGRect.zero) {
    didSet {
      view.addSubview(miniPlayerView)
      miniPlayerView.snp.makeConstraints { make in
        make.left.equalTo(view).offset(0)
        make.right.equalTo(view).offset(0)
        make.bottom.equalTo(tabBar.snp.top)
        make.height.equalTo(MiniPlayerView.viewHeight)
      }
      miniPlayerView.isHidden = true
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllers = [main.navigationController]
    miniPlayerView = MiniPlayerView(frame: CGRect.zero)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let items = tabBar.items else {
      fatalError()
    }
    assert(tabBarItemInfos.count == items.count)
    for (index, item) in items.enumerated() {
      item.title = tabBarItemInfos[index].title
      item.image = tabBarItemInfos[index].image
      item.selectedImage = tabBarItemInfos[index].selectedImage
    }
  }
}
