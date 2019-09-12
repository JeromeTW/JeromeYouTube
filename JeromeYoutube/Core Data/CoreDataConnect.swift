//
//  CoreDataConnect.swift
//
//  Created by JEROME on 2016/10/18.
//  Copyright © 2016年 JEROME. All rights reserved.
//

import CoreData
import Foundation

class CoreDataConnect {
  var myContext: NSManagedObjectContext!

  init(context: NSManagedObjectContext) {
    myContext = context
  }

  // insert
  func insert(_ myEntityName: String, attributeInfo: [String: Any]) -> Bool {
    let insetData = NSEntityDescription.insertNewObject(forEntityName: myEntityName, into: myContext)

    for (key, value) in attributeInfo {
      insetData.setValue(value, forKey: key)
    }

    do {
      try myContext.save()

      return true
    } catch {
      fatalError("\(error)")
    }
  }

  // retrieve
  func retrieve(_ myEntityName: String, predicate: NSPredicate?, sort: [[String: Bool]]?, limit: Int?) -> [NSManagedObject]? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)

    // predicate
    request.predicate = predicate

    // sort
    if let mySort = sort {
      var sortArr: [NSSortDescriptor] = []
      for sortCond in mySort {
        for (k, v) in sortCond {
          sortArr.append(NSSortDescriptor(key: k, ascending: v))
        }
      }

      request.sortDescriptors = sortArr
    }

    // limit
    if let limitNumber = limit {
      request.fetchLimit = limitNumber
    }

    do {
      return try myContext.fetch(request) as? [NSManagedObject]

    } catch {
      fatalError("\(error)")
    }
  }

  // update
  func update(_ myEntityName: String, predicate: NSPredicate?, attributeInfo: [String: String]) -> Bool {
    if let results = self.retrieve(myEntityName, predicate: predicate, sort: nil, limit: nil) {
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

      do {
        try myContext.save()

        return true
      } catch {
        fatalError("\(error)")
      }
    }

    return false
  }

  // delete
  func delete(_ myEntityName: String, predicate: NSPredicate?) -> Bool {
    if let results = self.retrieve(myEntityName, predicate: predicate, sort: nil, limit: nil) {
      for result in results {
        myContext.delete(result)
      }

      do {
        try myContext.save()

        return true
      } catch {
        fatalError("\(error)")
      }
    }

    return false
  }

  func getCount(_ myEntityName: String, predicate: NSPredicate?) -> Int {
    var count = 0
    let request = NSFetchRequest<NSNumber>(entityName: myEntityName)

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

  public func getFRC(_ myEntityName: String, predicate: NSPredicate?, sort: [[String: Bool]]?, limit: Int?) -> NSFetchedResultsController<NSFetchRequestResult> {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)

    // predicate
    request.predicate = predicate

    // sort
    if let mySort = sort {
      var sortArr: [NSSortDescriptor] = []
      for sortCond in mySort {
        for (k, v) in sortCond {
          sortArr.append(NSSortDescriptor(key: k, ascending: v))
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
