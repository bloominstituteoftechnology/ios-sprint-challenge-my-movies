//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Eoin Lavery on 25/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    //MARK: - Extension Properties
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else {
            return nil
        }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    //MARK: - Extension Convenience Initialisers
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(title: movieRepresentation.title, identifier: movieRepresentation.identifier ?? UUID(), hasWatched: movieRepresentation.hasWatched ?? false)
    }
    
}
