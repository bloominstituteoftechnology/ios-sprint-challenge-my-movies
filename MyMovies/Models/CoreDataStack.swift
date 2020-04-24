//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Cameron Collins on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    //Singleton
    static let shared = CoreDataStack()
    
    //Creating Persistent Container
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading persistent store: \(error)")
            }
        }
        return container
    }()
    
    
    //Getting Context
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
