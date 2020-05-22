//
//  Task+Convenience.swift
//  MyMovies
//
//  Created by Nonye on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// MARK: - MOVIE EXTENSTION

extension Movie {
    
    @discardableResult convenience init(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
}
