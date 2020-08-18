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

    var movieController = MovieController()
    
    lazy var fetchedResultsControllers: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                                        NSSortDescriptor(key: "title", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            NSLog("Unable to fetch tasks from main context")
        }
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsControllers.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsControllers.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.resuseIdentifier, for: indexPath) as? MovieTableViewCell else {
            fatalError("Can't dequeue cell of type \(MovieTableViewCell.resuseIdentifier)")
        }
        
        cell.delegate = self
        cell.movie = fetchedResultsControllers.object(at: indexPath)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsControllers.sections?[section] else { return nil }
        return sectionInfo.name.capitalized
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsControllers.object(at: indexPath)
            movieController.deleteMovieFromServer(movie) { (result) in
                DispatchQueue.main.async {
                    guard let _ = try? result.get() else { return }
                    let moc = CoreDataStack.shared.mainContext
                    moc.delete(movie)
                    do {
                        try moc.save()
                    } catch {
                        moc.reset()
                        NSLog("Error saving managed object context: \(error)")
                    }
                }


            }
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "AddMovieSegue":
            if let navController = segue.destination as? UINavigationController,
                let movieVC = navController.viewControllers.first as? MovieSearchTableViewController {
                movieVC.movieController = self.movieController
            }
        default:
            break
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}

extension MyMoviesTableViewController: MovieCellDelegate {
    func didUpdateMove(cell: MovieTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        let movie = fetchedResultsControllers.object(at: indexPath)
        movie.hasWatched.toggle()
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Errer not able to save move title: \(error)")
        }
        
    }

}




