//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Mitchell Budge on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, identifier: UUID, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let title = movieRepresentation.title
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: title, identifier: identifier, hasWatched: hasWatched, context: context)
    }

    var movieRepresentation: MovieRepresentation {
        guard let title = title else { fatalError() }
        if identifier == nil {
            identifier = UUID()
        }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
}
