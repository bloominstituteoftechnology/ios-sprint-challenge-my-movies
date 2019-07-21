//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack() // So that we can use CoreDataStack.shared.mainContext in other classes.
    
    lazy var container: NSPersistentContainer = { // A container that encapsulates Core Data in the project.
        let container = NSPersistentContainer(name: "Movie") // Name of the xcDataModel
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
}
