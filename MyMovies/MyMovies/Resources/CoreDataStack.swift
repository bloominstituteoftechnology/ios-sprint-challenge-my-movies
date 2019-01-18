//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "Movies")
        
        //Loads movie data from the Movies data object
        container.loadPersistentStores { (description, error) in
            if let loadError = error { fatalError("Couldn't load the data store: \(loadError)") }
        } //End of Load
        
        //Merge any changes
        container.viewContext.automaticallyMergesChangesFromParent = true

        //Initialise the Main Context
        mainContext = container.viewContext

    } // End of Init
    
    //Save after merging changes
    static func saveAfterMerging(moc: NSManagedObjectContext) throws {
        
        var theError: Error? //Allow for an error
        
        moc.performAndWait {
            
            do {
                try moc.save() //Attempt to save
                
            } catch {
                
                theError = error //If there's an error, assign it for use
            }
        } //End of Perform and Wait
        
        if let SAMerror = theError { //Unwrap the error
            throw SAMerror //Report the error
        }
    }

}//End of CoreData Stack
