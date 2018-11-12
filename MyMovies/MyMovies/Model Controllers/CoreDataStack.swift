//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Yvette Zhukovsky on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//


import Foundation
import CoreData


class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        
        if let error = error {
            throw error
            
        }
       
    }
 
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}

