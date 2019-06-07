//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(title: movieRepresentation.title, identifier: movieRepresentation.identifier!, hasWatched: movieRepresentation.hasWatched!, context: context)
        
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        var movieIdentifier: UUID! = identifier
        if identifier == nil {
            movieIdentifier = UUID()
            identifier = movieIdentifier
        }
        
        return MovieRepresentation(title: title, identifier: movieIdentifier, hasWatched: hasWatched)
    }
    
    
}
