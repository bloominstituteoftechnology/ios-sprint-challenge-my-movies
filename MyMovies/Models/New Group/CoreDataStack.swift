//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Percy Ngan on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

	static let shared = CoreDataStack()

	private init() {
		
	}

//	lazy var container: NSPersistentContainer = {
//
//		let container = NSPersistentContainer(name: "Movies")
//		container.loadPersistentStores(completionHandler: { (_, error) in
//			if let error = error {
//				fatalError("Unable to load persistent store: \(error)")
//			}
//		})
//
//		return container
//	}()


	var backgroundContext: NSManagedObjectContext {
		return container.newBackgroundContext()
	}

	func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		context.performAndWait {
			do {
				try context.save()
			} catch {
				NSLog("Unable to save context: \(error)")
				context.reset()
			}
		}
	}



	let container: NSPersistentContainer = {

		let container = NSPersistentContainer(name: "MovieCoreData" as String)
		container.loadPersistentStores() { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()

	var mainContext: NSManagedObjectContext { return container.viewContext }
}
