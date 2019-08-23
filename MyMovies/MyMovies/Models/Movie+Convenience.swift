//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String, identifier: String = UUID().uuidString, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let title = movieRepresentation.title,
              let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else{ return nil }
        
        self.init(title: title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}

