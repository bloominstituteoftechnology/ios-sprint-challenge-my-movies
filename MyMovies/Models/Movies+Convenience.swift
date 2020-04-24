//
//  Movies+Convenience.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let id = identifier,
            let title = title else {
                 return nil
        }
        
        return MovieRepresentation(title: title, identifier: id, hasWatched: hasWatched)
    }
    
    
    @discardableResult convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let mIdentifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        
        self.init(title: movieRepresentation.title,
                  identifer: mIdentifier,
                  hasWatched: hasWatched,
                  context: context)
        
    }
    
    
    
    @discardableResult convenience init(title: String,
                                        identifer: UUID = UUID(),
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
        
    }
    
}

