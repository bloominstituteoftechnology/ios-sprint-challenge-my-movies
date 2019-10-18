//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Percy Ngan on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

	static let shared = CoreDataStack()

	private init() {

	}

	var backgroundContext: NSManagedObjectContext {

	}

	var mainContext: NSManagedObjectContext { return container.}

	func save(context: NSManagedObjectContext = CoreDataStack.shared.main)


}
