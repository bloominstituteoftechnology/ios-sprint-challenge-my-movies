//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (_, error) in
            if let error = error { fatalError("Error loading from NSPersistentContainer: \(error)") }
        }
        //Merging any changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container }() //End of container
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext }
    
    //Saving after merging changes
    static func save(moc:NSManagedObjectContext) throws
    {
        var saveError:Error?
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                saveError = error
            }
        }
        
        if let saveError = saveError {
            throw saveError
        }
    }
    
}//End of CoreDataStack
