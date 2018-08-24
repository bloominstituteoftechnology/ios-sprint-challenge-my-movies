//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Andrew Dhan on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context:NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext){
        self.init(context: context)
        self.title = movieRepresentation.title
        self.identifier = movieRepresentation.identifier
        self.hasWatched = movieRepresentation.hasWatched!
    }
}
