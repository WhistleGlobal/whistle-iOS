//
//  CoreDataManager.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreData
import Foundation

struct CoreDataManager {
  let mainContext: NSManagedObjectContext

  init(mainContext: NSManagedObjectContext) {
    self.mainContext = mainContext
  }

  func fetchProjects() -> [ProjectEntity] {
    let fetchRequest = ProjectEntity.request()

    do {
      let projects = try mainContext.fetch(fetchRequest)
      return projects
    } catch {
      print("Failed to fetch FoodEntity: \(error)")
    }
    return []
  }
}
