//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Madison Waters on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String,
                     identifier: UUID = UUID(),
                     watched: Bool = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.watched = watched
    }

    
    convenience init?(movieRepresentation mr: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let identifier = UUID(uuidString: mr.identifier!),
            let watched = mr.watched else { return nil }

        self.init(title: mr.title,
                  identifier: identifier,
                  watched: watched,
                  context: context)
    }
}
