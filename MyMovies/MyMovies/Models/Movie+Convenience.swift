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
    convenience init(title: String, identifier: UUID? = UUID(), hasWatched: Bool? = false, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched!
    }
}
