//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jessie Ann Griffin on 10/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String,
                     identifier: UUID? = UUID(),
                     hasWatched: Bool? = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        
        guard let hasWatched = hasWatched else { return }
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        self.init(title: movieRepresentation.title,
                  identifier: movieRepresentation.identifier,
                  hasWatched: movieRepresentation.hasWatched,
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
