//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
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
    
    //failable initializer for creating a Movie with the attributes of a MovieRepresentation
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { print("Error unwrapping identifier/haswatched in failable initializer"); return nil }
        self.init(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
    
    //create a computed property to return a movieRepresentation constructed from the attributes of a Movie
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { print("Error initializing a movieRep from a Movie") ; return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
