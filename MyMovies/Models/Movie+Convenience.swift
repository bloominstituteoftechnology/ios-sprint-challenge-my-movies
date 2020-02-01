//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jorge Alvarez on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// Might not work
extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else {return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    // Create a new managed object in Core Data
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool? = false,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched ?? false //?
        self.identifier = identifier
        
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRepresentation.identifier else {return nil}
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched,
                  identifier: identifier,
                  context: context)
    }
}
