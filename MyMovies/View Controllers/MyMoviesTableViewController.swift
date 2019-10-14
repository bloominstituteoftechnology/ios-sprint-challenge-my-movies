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

    //MARK: - PROPERTIES
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "hasWatched", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("Error fetching movies from local storage: \(error)")
        }
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedMoviesController.shared.fetchMoviesFromServer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        tableView.reloadData()
    }

    // MARK: - TABLE VIEW DATA SOURCE
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections?.count {
            return sections
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfObjects = fetchedResultsController.sections?[section].numberOfObjects {
            return numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil}
        if sectionInfo.name == "0" {
            return "Not Seen"
        } else {
            return "Seen"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? SavedMoviesTableViewCell else { return UITableViewCell() }
        cell.movie = fetchedResultsController.object(at: indexPath)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            SavedMoviesController.shared.deleteMovieFromServer(movie: movie) { (error) in
                if let error = error {
                    print("Error deleting movie from online server: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    SavedMoviesController.shared.deleteMovie(for: movie)
                }
            }
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
           // newIndexPath is optional bc you'll only get it for insert and move
           
           switch type {
           case .insert:
               guard let newIndexPath = newIndexPath else { return }
               tableView.insertRows(at: [newIndexPath], with: .automatic)
           case .update:
               guard let indexPath = indexPath else { return }
               tableView.reloadRows(at: [indexPath], with: .automatic)
           case .move:
               guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
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
