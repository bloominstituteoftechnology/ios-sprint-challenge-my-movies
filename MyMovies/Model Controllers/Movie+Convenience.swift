//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by BDawg on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String,
                     hasWatched: Bool = false,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(title: movieRepresentation.title,
                  identifier: movieRepresentation.identifier ?? UUID(),
                  context: context)
    }
}
