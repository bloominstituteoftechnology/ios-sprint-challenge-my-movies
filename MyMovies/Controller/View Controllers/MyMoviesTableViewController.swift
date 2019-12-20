//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import CoreData
import UIKit

class MyMoviesTableViewController: UITableViewController {
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Properties
    let movieController = MovieController()
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        movieController.fetchMoviesFromServer { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table View DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cells.myMovieCell, for: indexPath) as? MyMovieTableViewCell else { return UITableViewCell() }
        cell.movie = fetchedResultsController.object(at: indexPath)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let movie = fetchedResultsController.object(at: indexPath)
            movieController.deleteMovieFromServer(movie: movie) { error in
                if let error = error {
                    print("Error deleting movie from server: \(error.localizedDescription)")
                    return
                }
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                do {
                    try moc.save()
                } catch let saveError {
                    moc.reset()
                    print("Error saving managed object context: \(saveError.localizedDescription)")
                }
            }
        default:
            break
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name == "1" ? "Watched" : "Not Watched"
    }
}

// MARK: - NSFetchedResultsController Delegate Extension
extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let fromIndexPath = indexPath, let toIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [fromIndexPath], with: .automatic)
            tableView.insertRows(at: [toIndexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}

// MARK: - MyMovieCellDelegate Extension
extension MyMoviesTableViewController: MyMovieCellDelegate {
    func didWatchMovie(for cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let movie = fetchedResultsController.object(at: indexPath)
        movie.hasWatched.toggle()
        movieController.put(movie: movie)
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        try? CoreDataStack.shared.save(context: moc)
    }
}
