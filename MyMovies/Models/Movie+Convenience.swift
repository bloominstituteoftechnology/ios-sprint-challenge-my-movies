//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Bronson Mullens on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = self.title else { return nil }
        
        return MovieRepresentation(identifier: identifier?.uuidString ?? "",
                                   title: title,
                                   hasWatched: hasWatched)
    }
    
    // Inititalizer to convert Movie into representation
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
        
    }
    
    // Initializer to convert representation into Movie
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier) else { return nil }
        
        self.init(identifier: identifier,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched,
                  context: context)
    }
}
