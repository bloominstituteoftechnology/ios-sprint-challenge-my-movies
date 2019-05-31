//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
	}
	
	lazy var fetchedResultController: NSFetchedResultsController<Movie> = {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
		let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
															   managedObjectContext: CoreDataStack.shared.mainContext,
															   sectionNameKeyPath: "hasWatched",
															   cacheName: nil)
		fetchResultController.delegate = self
		
		do {
			try fetchResultController.performFetch()
		} catch {
			NSLog("Error performing initial fetch for frc")
		}
		
		return fetchResultController
	}()
	
}
