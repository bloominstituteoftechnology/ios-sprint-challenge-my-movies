//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Conner on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
  convenience init(title: String,
                   identifier: UUID,
                   hasWatched: Bool,
                   context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
    self.init(context: context)
    
    self.title = title
    self.identifier = identifier
    self.hasWatched = hasWatched
  }
}
