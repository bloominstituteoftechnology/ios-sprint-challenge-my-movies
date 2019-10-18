//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController {

	let movieController = MovieController()

	lazy var fetch: NSFetchedResultsController<Movie> = {

		let request: NSFetchRequest<Movie> = Movie.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true)]

		let frc = NSFetchedResultsController(fetchRequest: request,
											 managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "hasWatched", cacheName: nil)

		frc.delegate = self

		do {
			try frc.performFetch()
		} catch {
			fatalError("Error performing fetch for frc: \(error)")
		}
		return frc
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.clearsSelectionOnViewWillAppear = false
		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Table view data source

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if section == 0 {
			return "Unwatched"
		} else {
			return "Watched"
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetch.sections?.count ?? 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return fetch.sections?[section].numberOfObjects ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMoviesTableViewCell else { return UITableViewCell() }

		cell.movieController = movieController
		cell.movie = fetch.object(at: indexPath)

		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {

			let movie = fetch.object(at: indexPath)
			movieController.delete(movie: movie)
		}
	}
}

extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else {return}
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else {return}
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let newIndexPath = newIndexPath,
				let indexPath = indexPath else {return}
			tableView.moveRow(at: indexPath, to: newIndexPath)
		case .update:
			guard let indexPath = indexPath else {return}
			tableView.reloadRows(at: [indexPath], with: .automatic)
		@unknown default:
			return
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

		let set = IndexSet(integer: sectionIndex)
		switch type {
		case .insert:
			tableView.insertSections(set, with: .automatic)
		case .delete:
			tableView.deleteSections(set, with: .automatic)
		default:
			return
		}
	}
}
