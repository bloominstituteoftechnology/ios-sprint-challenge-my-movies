//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Singleton Pattern
    
    static let shared = CoreDataStack()
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        
        var error: Error? // For throws function will need an optional Error
        
        // This performs given code inside the context's queue
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    // MARK: - Persistent Container
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyMovies") // Needs to match up with data model/app name
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistenet stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true // Parent - Child
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
