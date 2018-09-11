//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, watchedTitle: String = "Unwatched", identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.watchedTitle = watchedTitle
        self.identifier = identifier
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        
        return MovieRepresentation(title: title!, identifier: identifier, hasWatched: hasWatched)
    }
}
