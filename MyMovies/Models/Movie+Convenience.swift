//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Andrew Ruiz on 10/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title,
            /// No need to unwrap hasWatched, since it's not an optional.
            //let hasWatched = hasWatched,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
        
    }
    
    // This initializer sets up the Core Data (NSManagedObject) part of the Task, then gives it the properties unique to a Task entity.
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext) {
        
        // Calling the designated initializer
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }

    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
        // We have to unwrap again, because identifier and hasWatched are optionals in the Movie Representation file and we can't change it (I believe the data is built that way)
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }
}
