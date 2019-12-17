//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Craig Swanson on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier?.uuidString ?? UUID().uuidString, hasWatched: hasWatched)
    }
    
    convenience init(title: String,
                     identifier: UUID? = UUID(),
                     hasWatched: Bool? = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
//        self.hasWatched = hasWatched
        }
    
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifierString = movieRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else { return nil }
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: movieRepresentation.hasWatched, context: context)
    }
}
