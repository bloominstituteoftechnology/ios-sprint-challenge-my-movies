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
    
    //  manages fetch requests [of Movie entities]
    lazy var fetch: NSFetchedResultsController<Movie> = {
    
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(key: "hasWatched", ascending: true),
                                    NSSortDescriptor(key: "title", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        
        //  fetched results controller
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("error performing fetch for frc: \(error)")
        }
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        movieController.fetch {_ in 
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetch.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetch.sections?[section].numberOfObjects ?? 0
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.resuseIdentifier, for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.movie = fetch.object(at: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetch.sections?[section] else { return nil }
        
        switch sectionInfo.name {
        case "0":
            return "unwatched"
        case "1":
            return "watched"
        default:
            return "coming soon"
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetch.object(at: indexPath)
            let moc = CoreDataStack.shared.mainContext
            moc.delete(movie)
            
            do {
                try moc.save()
            } catch {
                moc.reset()
                NSLog("error saving managed object context: \(error)")
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
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

extension MyMoviesTableViewController: MovieCellDelegate {
    func didUpdateMovie(movie: Movie) {
        movieController.sendMovieToFirebase(movie: movie)
    }
}
