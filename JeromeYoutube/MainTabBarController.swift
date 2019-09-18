//
//  MainTabBarController.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/18.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  init() {
    super.init(nibName: nil, bundle: nil)
    let storyboard = UIStoryboard(name: "CategoryListTab", bundle: Bundle.main)
    let categoryListVC = CategoryListVC.instantiate(storyboard: storyboard)
    let categoryListViewControllerInfo = ViewControllerInfo(hasNavigation: true, viewController: categoryListVC, tabBarItem: UITabBarItem(title: "List", image: nil, selectedImage: nil))
    setupViewControllers([categoryListViewControllerInfo])
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
