//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Dennis Rudolph on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        //May have to check if the movie rep already has identifier or haswatched
        self.init(title: movieRepresentation.title, identifier: UUID(), hasWatched: false, context: context)
      }
    
    var movieRepresentation: MovieRepresentation? {

        guard let title = title,
            let identifier = identifier else {
                return nil
        }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    var firebaseMovieRep: FirebaseMovieRep? {
        guard let title = title,
                   let identifier = identifier else {
                       return nil
            }
        return FirebaseMovieRep(title: title, identifier: identifier.uuidString, hasWatched: hasWatched)
}
}
