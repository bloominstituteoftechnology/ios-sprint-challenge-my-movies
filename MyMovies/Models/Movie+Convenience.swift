//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Taylor Lyles on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
	
	convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext) {
		
		self.init(context: context)
		
		self.title = title
		self.identifier = identifier
		self.hasWatched = hasWatched
		
	}
	
}
