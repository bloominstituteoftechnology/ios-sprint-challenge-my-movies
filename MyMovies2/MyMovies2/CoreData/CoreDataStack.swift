//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (_, error) in
            
            if let error = error {
                fatalError("Failded to load: \(error)")
            }
        }

        return container
        
        
    } ()
    
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
        
    }
        
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
                print("saved to persistent store")
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }

    func makeNewFetchedResultsController() -> NSFetchedResultsController<Movie> {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "hasWatched", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: mainContext,
                                             sectionNameKeyPath: "hasWatched",
                                             cacheName: nil)
        
        return frc
        
        
    }
        
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

