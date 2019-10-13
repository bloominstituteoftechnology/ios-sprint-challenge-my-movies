//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Michael Flowers on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
//When we get a "movie" back from the server it might fail, so we have to make this a failable initializer. This is to take the properties of the MovieRepresentation (movie we get back from the server) and use those properties to initialize our Movie object (the one we've constructed in core data) and save it to its appropriate context
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { print("Error unwrapping identifier/haswatched in failable initializer"); return nil }
        self.init(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
    
    //instead of making another convenience initializer, we create this computed property to initialize (make) a movieRepresentation so that we can send it to the server. Notice how there is no context associated with this variable.
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { print("Error initializing a movieRep from a Movie") ; return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}

