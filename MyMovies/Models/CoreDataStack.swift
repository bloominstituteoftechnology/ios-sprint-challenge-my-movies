//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by macbook on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // Let us access the CoreDataStack from anywhere in the app.
    static let shared = CoreDataStack()
    
    // Set up a persistent container
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        //MARK: Automatically merging changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // Create easy access to the moc (managed object context)
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
          context.performAndWait {
              do {
                  try context.save()
              } catch {
                  NSLog("Error saving context: \(error)")
                  context.reset()
              }
          }
      }
    
    func saveToPersistentStore() {
        do {
            try mainContext.save()
        } catch {
            NSLog("Error saving context: \(error)")
            mainContext.reset()
        }
    }
}

