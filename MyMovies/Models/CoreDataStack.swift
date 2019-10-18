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
		return container.newBackgroundContext()
	}

	var mainContext: NSManagedObjectContext { return container.viewContext}

	func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

		context.performAndWait {

			do {
				try context.save()
			} catch {
				NSLog("Unable to save to context: \(error)")
				context.reset()
			}
		}
	}

	let container: NSPersistentContainer = {

		let container = NSPersistentContainer(name: "MovieCoreData" as String)
		container.loadPersistentStores() { (storeDescription, error) in
			if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}

		container.viewContext
		.automaticallyMergesChangesFromParent = true
		return container
	}()
}
