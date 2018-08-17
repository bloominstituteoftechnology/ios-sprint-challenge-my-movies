//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jonathan T. Miles on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        //guard let identifier = UUID(uuidString: movieRepresentation.identifier) else { return nil }
        self.init(title: movieRepresentation.title, identifier: movieRepresentation.identifier ?? UUID(), hasWatched: movieRepresentation.hasWatched ?? false, managedObjectContext: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title
            // let identifier = identifier
            // let hasWatched = hasWatched
            else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
