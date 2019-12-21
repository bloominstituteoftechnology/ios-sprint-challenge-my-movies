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
    
    convenience init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext, hasWatched: Bool, identifier: String = UUID().uuidString, title: String) {
        self.init(context: context)
        self.hasWatched = hasWatched
        self.identifier = identifier
        self.title = title
    }
    
}
