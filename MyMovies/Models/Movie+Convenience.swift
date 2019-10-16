//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Bobby Keffury on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum MovieWatched {
    
    case watched
    case unwatched
    
}


extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool? = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
        
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
        
    }
    
}
