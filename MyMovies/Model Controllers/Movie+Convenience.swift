//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier
            else { return nil}
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(identifier: UUID = UUID(), title: String, hasWatched: Bool = false, context: NSManagedObjectContext) {
        
        // Setting up the generic NSManagedObject functionality of the model object
        // The generic chunk of clay
        self.init(context: context)
        
        // Once we have the clay, we can begin sculpting it into our unique model object
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentaion: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = movieRepresentaion.identifier,
        let hasWatched = movieRepresentaion.hasWatched
            else { return nil }
        
        self.init(identifier: identifier, title: movieRepresentaion.title, hasWatched: hasWatched, context: context)
    }
    
    func toggleHasWatched () {
        self.hasWatched = !self.hasWatched
    }
}
