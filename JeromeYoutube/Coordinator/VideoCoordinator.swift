// VideoCoordinator.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit

class VideoCoordinator: Coordinator {
  var navigationController: CoordinatedNavigationController
  let storyboard = UIStoryboard(name: "CategoryListTab", bundle: Bundle.main)

  init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
    self.navigationController = navigationController
    navigationController.navigationBar.prefersLargeTitles = true
    navigationController.coordinator = self

    let categoryListVC = CategoryListVC.instantiate(storyboard: storyboard)
    categoryListVC.videoCoordinator = self
    navigationController.navigationBar.isHidden = true
    navigationController.viewControllers = [categoryListVC]
  }

  func videoCategoryDetail(category: VideoCategory) {
    let categoryDetailVC = CategoryDetailVC.instantiate(storyboard: storyboard)
    categoryDetailVC.category = category
    categoryDetailVC.videoCoordinator = self
    navigationController.pushViewController(categoryDetailVC, animated: true)
  }
}
