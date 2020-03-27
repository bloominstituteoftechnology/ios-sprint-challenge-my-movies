//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Karen Rodriguez on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil}
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    // Convenience initializer for creating a movie directly into coreData. May never be used, but gotta get those reps in you feel me.
    @discardableResult convenience init (identifier: UUID = UUID(), title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    //  Failable convenience initializer for converting a representation into core data.
    @discardableResult convenience init?(representation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(identifier: representation.identifier ?? UUID(), title: representation.title, hasWatched: representation.hasWatched ?? false, context: context)
    }
}
