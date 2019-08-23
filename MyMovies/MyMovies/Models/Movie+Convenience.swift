//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Bradley Yin on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    // create from getting info from user
    @discardableResult convenience init(title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext, identifier: UUID = UUID()) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    //TaskRepresentation -> Task
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let title = movieRepresentation.title
        
        self.init(title: title, context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title ?? "", identifier: identifier, hasWatched: hasWatched)
    }
    
}
