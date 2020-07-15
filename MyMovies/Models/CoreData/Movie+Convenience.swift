//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
  convenience init(title: String, hasWatched: Bool, identifier: UUID, context: NSManagedObjectContext) {
    self.init(context: context)
    self.title = title
    self.hasWatched = hasWatched
    self.identifier = identifier
  }
}
