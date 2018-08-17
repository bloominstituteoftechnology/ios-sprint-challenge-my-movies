//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Linh Bouniol on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = UUID()
    }
    
    @discardableResult
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false, // if hasWatched is nil, set watched to false
                  context: context)
        
        self.identifier = movieRepresentation.identifier ?? UUID() // if identifier is nil, generate a new one
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
