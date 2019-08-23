//
//  MyMoviesTableVC.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableVC: UITableViewController {
	
	//MARK: - Properties
	
	var movieController = MovieController()
	
	lazy var fetchResultsController: NSFetchedResultsController<Movie> = {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: false),
										NSSortDescriptor(key: "title", ascending: true)]
		
		let fetchControl = NSFetchedResultsController(fetchRequest: fetchRequest,
													  managedObjectContext: CoreDataStack.shared.mainContext,
													  sectionNameKeyPath: "hasWatched",
													  cacheName: nil)
		
		fetchControl.delegate = self
		
		do {
			try fetchControl.performFetch()
		} catch {
			fatalError("Error performing fetch for fetchControl: \(error)")
		}
		
		return fetchControl
	}()
	
	//MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		movieController.fetchCollection { (_) in
			
		}
	}
	
	//MARK: - Helpers
	

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return fetchResultsController.sections?[section].name
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMovieCell else { return UITableViewCell() }
		let movie = fetchResultsController.object(at: indexPath)
		
		cell.movie = movie
		cell.delegate = self
		cell.indexPath = indexPath

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let movie = fetchResultsController.object(at: indexPath)
		
        if editingStyle == .delete {
            movieController.delete(movie: movie)
        }
    }

}

extension MyMoviesTableVC: MyMovieCellDelegate {
	func watchStatusToggle(for movie: Movie, at indexPath: IndexPath) {
		movie.hasWatched.toggle()
		movieController.update(movie: movie)
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
}

extension MyMoviesTableVC: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
			tableView.moveRow(at: oldIndexPath, to: newIndexPath)
		case .update:
			guard let indexPath = indexPath else { return }
			tableView.reloadRows(at: [indexPath], with: .automatic)
		@unknown default:
			fatalError()
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let sectionIndexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert:
			tableView.insertSections(sectionIndexSet, with: .automatic)
		case .delete:
			tableView.deleteSections(sectionIndexSet, with: .automatic)
		default:
			break
		}
	}
}
