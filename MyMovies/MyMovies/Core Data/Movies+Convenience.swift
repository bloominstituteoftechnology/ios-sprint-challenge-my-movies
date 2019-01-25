//
//  Movies+Convenience.swift
//  MyMovies
//
//  Created by jkaunert on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(identifier: UUID = UUID(),
                     title: String,
                     hasWatched: Bool = false,
                     managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
        
    }
    
    // Movie from Representation
    convenience init(representation: MovieRepresentation, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        //calls movie convenience init()
        self.init(identifier: representation.identifier ?? UUID(),
                  title: representation.title,
                  hasWatched: representation.hasWatched ?? false,
                  managedObjectContext: managedObjectContext)
        
    }
    
    // Representation from Movie
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        var movieID: UUID! = identifier
        if identifier == nil {
            movieID = UUID()
            identifier = movieID
        }
        //return new representation
        return MovieRepresentation(title: title, identifier: movieID,
                                   hasWatched: hasWatched)
    }
    
}
