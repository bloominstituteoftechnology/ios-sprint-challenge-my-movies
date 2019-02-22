//
//  UpdateController.swift
//  MyMovies
//
//  Created by Nathanael Youngren on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

class UpdateController {
    
    let moc = CoreDataStack.shared.mainContext
    
    func update(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                moc.reset()
                NSLog("Error saving to persistent store")
            }
        }
    }
}
