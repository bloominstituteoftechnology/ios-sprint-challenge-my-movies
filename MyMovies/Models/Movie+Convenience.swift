//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_201 on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
    }
}
