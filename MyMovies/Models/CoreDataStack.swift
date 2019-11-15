//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Rick Wolter on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
     static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "Movie")
           
           container.loadPersistentStores { (_, error) in
               if let error = error {
                   fatalError("Error loading core data: \(error)")
               }
           }
           
           container.viewContext.automaticallyMergesChangesFromParent = true
           
           return container
       }()
    
    var mainContext: NSManagedObjectContext {
            return container.viewContext
        }
        
        func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    NSLog("Error saving context: \(error)")
                    context.reset()
                }
            }
        }
        
    }
