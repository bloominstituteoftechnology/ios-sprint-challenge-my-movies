//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Kat Milton on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    
    @discardableResult convenience init(title: String, identifier: UUID? = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = movieRepresentation.title
        self.identifier = movieRepresentation.identifier
        self.hasWatched = movieRepresentation.hasWatched!
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = self.title else { return nil}
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
}
