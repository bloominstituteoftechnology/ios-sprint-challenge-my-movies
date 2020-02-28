//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Elizabeth Wingate on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreData
import UIKit

class CoreDataStack {
    
    static let shared = CoreDataStack()
      let container: NSPersistentContainer
      
      let mainContext: NSManagedObjectContext
      
      init() {
        container = NSPersistentContainer(name: "MyMovies")
          
        container.loadPersistentStores { (description, error) in
          if let e = error {
            fatalError("Couldn't load the data store: \(e)")
        }
    }
        mainContext = container.viewContext
        mainContext.automaticallyMergesChangesFromParent = true
  }
    func makeNewFetchedResultsController() -> NSFetchedResultsController<Movie> {
         
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
         fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "hasWatched", ascending: true) ]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: mainContext,
                sectionNameKeyPath: "hasWatched", cacheName: nil)
         
         return frc
    }
    // Helper Method
    func saveTo(context: NSManagedObjectContext) throws {
        var saveError: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError { throw error }
    }
}
