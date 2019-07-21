//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieReprensentation: MovieRepresentation? {
        guard let title = self.title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRep.identifier,
            let hasWatched = movieRep.hasWatched else { return nil }
        self.init(title: movieRep.title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    
    
}
