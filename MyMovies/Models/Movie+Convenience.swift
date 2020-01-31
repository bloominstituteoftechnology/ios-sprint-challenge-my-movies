//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Zack Larsen on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
        let hasWatched = hasWatched,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, hasWatched: hasWatched, identifier: identifier)
    }
    
    @discardableResult convenience init(hasWatched: Bool, identifier: UUID = UUID(), title: String, context: NSManagedObjectContext = CoreDataStack.shared.container.newBackgroundContext()) {
        
        self.init(context: context)
        self.hasWatched = hasWatched
        self.title = title
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.container.newBackgroundContext()) {

        guard let hasWatched = movieRepresentation.hasWatched
             else { return nil
                
        }
        
        self.init(hasWatched: movieRepresentation.hasWatched, identifier: movieRepresentation.identifier, title: movieRepresentation.title, context: context)
        
    }
}
