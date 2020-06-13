//
//  Movie+Convienece.swift
//  MyMovies
//
//  Created by Clayton Watkins on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    //MARK: - Properties
    // Creating a computed property for our Movie Representaion
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        let id = identifier ?? UUID()
        return MovieRepresentation(title: title, identifer: id, hasWatched: hasWatched)
    }
    
    //MARK: - Convienece Initializers
    
    //Movie data object Initializer
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    // A second initializer to turn a Movie into a more digestable object format for json
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        guard let identifier = movieRepresentation.identifer else { return nil}
        
        self.init(identifier: identifier,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
    }
    
}
