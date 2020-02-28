//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack
{
    
    
    static let shared = CoreDataStack()
    
    lazy var container : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "My Journal - Core Data")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load container : \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext : NSManagedObjectContext {
        return container.viewContext
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
