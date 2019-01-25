//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//
import Foundation
import CoreData


// Manager for getting data
class CoreDataStack {
    
    // Singleton
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    // How we interact with our data store
    let mainContext: NSManagedObjectContext
    
    // Init method
    init() {
        
        // Alternative: Use NSPersistentContainer
        
        // Create a container
        // Give it the name of your data model file
        container = NSPersistentContainer(name: "MyMovies")
        
        // Load the stores
        container.loadPersistentStores { (description, error) in
            if let e = error {
                fatalError("Couldn't load the data store: \(e)")
            }
        }
        
        mainContext = container.viewContext
        mainContext.automaticallyMergesChangesFromParent = true
    }
    func save(context: NSManagedObjectContext) throws {
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
