//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Percy Ngan on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

	convenience init(title: String, identifier: UUID, hasWatched: Bool, context: NSManagedObjectContext) {

		self.init(context: context)
		self.title = title
		self.identifier = identifier
		self.hasWatched = hasWatched

	}
}
