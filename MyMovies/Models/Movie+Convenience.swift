//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Mark Gerrior on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

/// Because we choose class define in Movies.xcdaatamodeld, Movie gets generated behind the scenes
extension Movie {
    
    // TODO: ? Coming in from Firebase. Do not like this much magic.
    // FIXME: Is this right? And what do I need to unwrap? Or will I get errors to let me know?
    var movieRepresentation: MovieRepresentation? {
        guard let identifier = identifier,
            let title = title,
            let hasWatched = Bool?(hasWatched) else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier,
                                   hasWatched: hasWatched)
    }

    @discardableResult convenience init(identifier: UUID,
                     title: String,
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext) {
        /// Magic happens here
        self.init(context: context)
        
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }

    /// Convenience Initializer
    /// Items coming in from Firebase for Core Data
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(identifier: movieRepresentation.identifier!,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
    }
}

