// NSPersistentContainerExtension.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import CoreData

extension NSPersistentContainer {
  func saveContext(backgroundContext: NSManagedObjectContext? = nil) throws {
    let context = backgroundContext ?? viewContext
    guard context.hasChanges else { return }
    do {
      try context.save()
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      throw error
    }
  }
}
