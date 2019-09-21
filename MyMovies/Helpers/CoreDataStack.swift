//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Alex Rhodes on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {
        
    }
    
    // lazy doesn't initialize upone class initialization, it is only called when needed
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Core sata was unable to load persistence stores: \(error)")
            }
        })
        
        return container
    }()
    
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("error saving context: \(error)")
                context.reset()
            }
        }
    }
}
