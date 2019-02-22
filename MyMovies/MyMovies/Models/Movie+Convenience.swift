//
//  Movie.swift
//  MyMovies
//
//  Created by Angel Buenrostro on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    
    convenience init(title: String, identifier: UUID?, hasWatched: Bool?, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
    }
    
    @discardableResult
    convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext) {
        
        self.init(title: movieRep.title, identifier: movieRep.identifier, hasWatched: movieRep.hasWatched, context: context)
    }
}
