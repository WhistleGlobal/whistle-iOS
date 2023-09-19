//
//  RootViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreData
import Foundation
import PhotosUI
import SwiftUI

final class RootViewModel: ObservableObject {
  @Published var projects = [ProjectEntity]()
  private let dataManager: CoreDataManager

  init(mainContext: NSManagedObjectContext) {
    dataManager = CoreDataManager(mainContext: mainContext)
  }

  func fetch() {
    projects = dataManager.fetchProjects()
  }

  func removeProject(_ project: ProjectEntity) {
    ProjectEntity.remove(project)
    fetch()
  }
}
