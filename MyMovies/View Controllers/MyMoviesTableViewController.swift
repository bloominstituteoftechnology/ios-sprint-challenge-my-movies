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
    
    // MARK: - Properties
    
    let movieController = MovieController()
       
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
           let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                                           NSSortDescriptor(key: "title", ascending: true)]
           
           let context = CoreDataStack.shared.mainContext
           let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: "hasWatched",
                                                cacheName: nil)
           
           frc.delegate = self
           
           do {
               try frc.performFetch()
           } catch {
               NSLog("Error fetching moview from server: \(error)")
           }
           
           return frc
       }()

    override func viewDidLoad() {
        super.viewDidLoad()
}

    // MARK: - Table view data source

   override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MyMovieTableViewCell else { return UITableViewCell() }

        cell.delegate = self
        cell.movie = fetchedResultsController.object(at: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName = fetchedResultsController.sections?[section].name
  
        if sectionName == "0" {
            sectionName = "Not Watched"
        } else {
            sectionName = "Watched"
        }
        
        return sectionName
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            movieController.deleteMovie(movie: movie)
        }
    }
}

extension MyMoviesTableViewController: SeenMovieDelegate {
    func watched(movie: Movie) {
        movieController.watchedMovie(movie)
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
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let sectionSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
        default:
            return
        }
    }
}
