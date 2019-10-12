//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Fabiola S on 10/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, hasWatched: Bool, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifierString = movieRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString),
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
    guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier?.uuidString ?? "", hasWatched: hasWatched)
    }
}
