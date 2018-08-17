//
//  CoreDataManager.swift
//  MyMovies
//
//  Created by Conner on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
  
  static let shared = CoreDataManager()
  
  lazy var container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Journal")
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error {
        fatalError("Could not load Core Data from persistent store: \(error)")
      }
    })
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
  
  var mainContext: NSManagedObjectContext {
    return container.viewContext
  }
  
}
