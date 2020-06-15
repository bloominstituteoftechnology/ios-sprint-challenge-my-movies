//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.
    }
}


/*
 var identifier: String
    var title: String
    var hasWatched: Bool
 */
