//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Michael Redig on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
	convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		self.init(context: context)
		self.title = title
		self.identifier = identifier
		self.hasWatched = hasWatched
	}

	convenience init(fromRepresentation representation: MovieRepresentation, onContext context: NSManagedObjectContext) {
		let identifier = representation.identifier ?? UUID()
		let hasWatched = representation.hasWatched ?? false
		self.init(title: representation.title, identifier: identifier, hasWatched: hasWatched, context: context)
	}

	var movieRepresentation: MovieRepresentation? {
		var tTitle: String?
		var tID: UUID?
		managedObjectContext?.performAndWait {
			tTitle = title
			tID = identifier
		}
		guard let title = tTitle,
		let identifier = tID
			else { return nil }
		return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
	}

	var threadSafeID: UUID? {
		get {
			var id: UUID?
			managedObjectContext?.performAndWait {
				id = identifier
			}
			return id
		}
		set {
			managedObjectContext?.performAndWait {
				identifier = newValue
			}
		}
	}
}
