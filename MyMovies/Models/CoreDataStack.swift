//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Marc Jacques on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {

    }

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistant stores: \(error)")
            }

        })

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
