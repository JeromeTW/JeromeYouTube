//
//  CoreDataConnect.swift
//
//  Created by JEROME on 2016/10/18.
//  Copyright © 2016年 JEROME. All rights reserved.
//

import CoreData
import UIKit

class CoreDataConnect {
  lazy var persistentContainer: NSPersistentContainer = {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer
  }()
  
  var myContext: NSManagedObjectContext!

  init(context: NSManagedObjectContext) {
    myContext = context
  }

  // MARK: - Functions
  // insert
  // NOTE: myEntityName(在Video.xcdatamodeld中設定) 必須跟 class name 一致才能用範型
  func insert<T: NSManagedObject>(type: T.Type, attributeInfo: [String: Any]) -> Bool {
    let insetData = NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: myContext)

    for (key, value) in attributeInfo {
      insetData.setValue(value, forKey: key)
    }
    
    persistentContainer.saveContext(backgroundContext: myContext)
    return true
  }

  // retrieve
  func retrieve<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?, sort: [[String: Bool]]?, limit: Int?) -> [T]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))

    // predicate
    request.predicate = predicate

    // sort
    if let mySort = sort {
      var sortArr: [NSSortDescriptor] = []
      for sortCond in mySort {
        for (key, value) in sortCond {
          sortArr.append(NSSortDescriptor(key: key, ascending: value))
        }
      }

      request.sortDescriptors = sortArr
    }

    // limit
    if let limitNumber = limit {
      request.fetchLimit = limitNumber
    }

    do {
      return try myContext.fetch(request) as? [T]

    } catch {
      fatalError("\(error)")
    }
  }

  // update
  func update<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?, attributeInfo: [String: String]) -> Bool {
    if let results = self.retrieve(type: type, predicate: predicate, sort: nil, limit: nil) {
      for result in results {
        for (key, value) in attributeInfo {
          let t = result.entity.attributesByName[key]?.attributeType

          if t == .integer16AttributeType || t == .integer32AttributeType || t == .integer64AttributeType {
            result.setValue(Int(value), forKey: key)
          } else if t == .doubleAttributeType || t == .floatAttributeType {
            result.setValue(Double(value), forKey: key)
          } else if t == .booleanAttributeType {
            result.setValue(value == "true" ? true : false, forKey: key)
          } else {
            result.setValue(value, forKey: key)
          }
        }
      }
      persistentContainer.saveContext(backgroundContext: myContext)
      return true
    }
    return false
  }

  // delete
  func delete<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> Bool {
    if let results = self.retrieve(type: type, predicate: predicate, sort: nil, limit: nil) {
      for result in results {
        myContext.delete(result)
      }

      persistentContainer.saveContext(backgroundContext: myContext)
      return true
    }

    return false
  }

  func getCount<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> Int {
    var count = 0
    let request = NSFetchRequest<NSNumber>(entityName: String(describing: T.self))

    // predicate
    request.predicate = predicate
    request.resultType = .countResultType

    do {
      let countResult = try myContext.fetch(request)
      // 获取数量
      count = countResult.first!.intValue
    } catch let error as NSError {
      assertionFailure("Could not fetch \(error), \(error.userInfo)")
    }
    return count
  }

  public func getFRC<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?, sort: [[String: Bool]]?, limit: Int?) -> NSFetchedResultsController<NSFetchRequestResult> {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))

    // predicate
    request.predicate = predicate

    // sort
    if let mySort = sort {
      var sortArr: [NSSortDescriptor] = []
      for sortCond in mySort {
        for (key, value) in sortCond {
          sortArr.append(NSSortDescriptor(key: key, ascending: value))
        }
      }

      request.sortDescriptors = sortArr
    }

    // limit
    if let limitNumber = limit {
      request.fetchLimit = limitNumber
    }
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: myContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
    do {
      try fetchedResultsController.performFetch()
    } catch {
      let fetchError = error as NSError
      printLog("\(fetchError), \(fetchError.userInfo)", level: .error)
    }

    return fetchedResultsController
  }
}

protocol HasID {
  var id: Int64 { get set }
}

// MARK: - HasID
extension CoreDataConnect {
  // This Entity must has id property
  func generateNewID<T: HasID>(_ hasIDType: T.Type) -> Int64 {
    var newID: Int64 = 1
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
    request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
    request.fetchLimit = 1
    
    do {
      let result = try myContext.fetch(request) as? [T]
      if let first = result?.first {
        newID = first.id + 1
      }
      return newID
    } catch {
      fatalError("\(error)")
    }
  }
}
