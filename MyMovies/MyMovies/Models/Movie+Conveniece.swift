//
//  Movie+Conveniece.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData
extension Movie {
	
	convenience init (title: String, identifier: UUID = UUID(), hasWatched: Bool = false,
					  context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		self.init(context: context)
		self.title = title
		self.identifier = identifier
		self.hasWatched = hasWatched
	}
	
	
	
}
