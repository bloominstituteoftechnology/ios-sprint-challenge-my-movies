//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    // Used for converting a MovieRepresentation from Firebase to a Movie object
    convenience init?(movieRepresentation: MovieRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else {
                // We don't have enough information to create a Movie object, return nil instead
                return nil
        }
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    
    // Used for sending the Movie object to Firebase
    var movieRepresentation: MovieRepresentation? {
        guard let title = title, let identifier = identifier else { return nil }

        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
