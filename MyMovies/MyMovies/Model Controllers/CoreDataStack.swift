//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by William Bundy on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack
{
	static var shared = CoreDataStack()

	lazy var container:NSPersistentContainer = {
		let con = NSPersistentContainer(name: "MyMovies")
		con.loadPersistentStores { _, error in
			if let error = error {
				fatalError("Failed to load persistent stores")
			}
		}
		con.viewContext.automaticallyMergesChangesFromParent = true
		return con
	}()

	var mainContext:NSManagedObjectContext { return container.viewContext }

	static func save(moc:NSManagedObjectContext) throws
	{
		var caughtError:Error?
		moc.performAndWait {
			do {
				try moc.save()
			} catch {
				caughtError = error
			}
		}

		if let caughtError = caughtError {
			throw caughtError
		}
	}
}
