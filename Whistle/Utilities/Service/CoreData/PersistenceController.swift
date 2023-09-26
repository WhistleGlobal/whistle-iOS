//
//  PersistenceController.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreData
import Foundation

struct PersistenceController {
  static let shared = PersistenceController()

  // Convenience
  var viewContext: NSManagedObjectContext {
    container.viewContext
  }

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "CoreDataContainer")

    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }

    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }
}
