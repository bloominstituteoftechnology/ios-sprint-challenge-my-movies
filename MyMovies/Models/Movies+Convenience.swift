//
//  Movies+Convenience.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movies {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
           return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
       }
    
    @discardableResult convenience init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext, hasWatched: Bool?, identifier: String?, title: String) {
        self.init(context: context)
        self.hasWatched = hasWatched ?? true
        self.identifier = identifier
        self.title = title
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
//        guard let identifierString = movieRepresentation.identifier,
//            let identifier = UUID(uuidString: identifierString) else { return nil }
        self.init(context: context, hasWatched: movieRepresentation.hasWatched!, identifier: movieRepresentation.identifier, title: movieRepresentation.title)
    }
    
   
    

    
}
