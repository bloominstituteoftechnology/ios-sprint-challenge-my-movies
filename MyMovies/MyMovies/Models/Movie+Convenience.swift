//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init (title: String, hasWatched: Bool, identifier: UUID, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init? (movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRepresentation.hasWatched, let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }
}
