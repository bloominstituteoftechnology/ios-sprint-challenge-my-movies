//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 8/16/20.
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
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

//    func saveMovie(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
//        
//    }

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
