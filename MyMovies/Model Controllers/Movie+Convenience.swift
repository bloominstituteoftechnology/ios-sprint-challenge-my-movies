//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by BDawg on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String,
                     hasWatched: Bool = false,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    var representation: MovieRepresentation? {
        guard let title = title,
            !title.isEmpty,
            let identifier = identifier else { return nil }
        return MovieRepresentation(title: title,
                                   identifier: identifier,
                                   hasWatched: hasWatched)
    }
    
    convenience init?(representation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard !representation.title.isEmpty,
            let hasWatched = representation.hasWatched,
            let identifier = representation.identifier
        else {
            return nil
        }
        
        self.init(title: representation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }

}
