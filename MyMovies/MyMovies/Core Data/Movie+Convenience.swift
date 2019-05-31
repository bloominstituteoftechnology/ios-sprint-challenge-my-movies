//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Michael Flowers on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData
extension Movie {
    
    //initializer for the Movie object on the main context
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    //Failable initializer for turning a MR into a Movie
    //JSON -> MovieRepresentation -> Movie
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        //because these are optional values I have to unwrap them.
        guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        //this is calling the Movie's original init method, I'm using the MR's properties to pass them in as arguments.
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    
    //Initializer for turning an Movie into a MovieRep
    //Movie -> MR -> JSON
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil } //id and hswtchd have default values so they don't need to be unwrapped.
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
