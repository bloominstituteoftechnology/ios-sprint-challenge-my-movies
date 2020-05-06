//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Lambda_School_loaner_226 on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveManagedObjectContext(moc: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        moc.performAndWait {
            do {
                try moc.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
}
