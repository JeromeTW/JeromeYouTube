//
//  ImageLoader.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/11.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class ImageLoader {
  static let shared = ImageLoader()
  private let imageCache = NSCache<AnyObject, AnyObject>()
  lazy var requestOperationDictionary = [URL: AsynchronousOperation]()

  lazy var queue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "ImageLoader"
    queue.maxConcurrentOperationCount = 4
    queue.qualityOfService = QualityOfService.userInitiated
    return queue
  }()
  
  // TODO: Operation
  func imageByURL(_ url: URL, completionHandler: @escaping (_ image: UIImage?, _ url: URL) -> ()) {
    // get image from cache
    if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
      completionHandler(imageFromCache, url)
      return
    } else {
      // if no image from cache, get image from url
      let request = APIRequest(url: url)
      func mainThreadCompletionHandler(image innerImage: UIImage?, _ url: URL) {
        DispatchQueue.main.async {
          completionHandler(innerImage, url)
        }
      }
      let operation = NetworkRequestOperation(request: request) { [weak self] result in
        guard let self = self else {
          assertionFailure()
          return
        }
        guard let operation = self.requestOperationDictionary[url] else {
          mainThreadCompletionHandler(image: nil, url)
          return
        }
        defer {
          self.requestOperationDictionary.removeValue(forKey: url)
          operation.completeOperation()
        }
        guard operation.isCancelled == false else {
          mainThreadCompletionHandler(image: nil, url)
          return
        }
        
        switch result {
        case .success(let response):
          if let data = response.body {
            if let image = UIImage(data: data) {
              self.imageCache.setObject(image, forKey: url as AnyObject)
              mainThreadCompletionHandler(image: image, url)
            } else {
              printLog("Data Format Wrong", level: .error)
              mainThreadCompletionHandler(image: nil, url)
            }
          } else {
            printLog("No Data", level: .error)
            mainThreadCompletionHandler(image: nil, url)
          }
          
        case .failure:
          printLog("failed", level: .debug)
          mainThreadCompletionHandler(image: nil, url)
        }
      }
      requestOperationDictionary[url] = operation
      queue.addOperation(operation)
    }
  }
}

//extension UIImageView {
//  func loadImage(from url: URL?) {
//    image = nil
//    
//    // get image from cache
//    if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
//      DispatchQueue.main.async {
//        self.image = imageFromCache
//        return
//      }
//      print("Here")
//    }
//    print("There")
//    // if no image from cache, get image from url
//    APIClient.shared.requestPlantImage(with: url) { [weak self] (result) in
//      switch result {
//      case .success(let response):
//        if let imageData = response.body {
//          DispatchQueue.main.async {
//            // set image to cache
//            guard let imageToCache = UIImage(data: imageData) else { return }
//            imageCache.setObject(imageToCache, forKey: url as AnyObject)
//            self?.image = imageToCache
//          }
//        }
//      case .failure:
//        printLog("Error perform network request")
//      }
//    }
//  }
//}

