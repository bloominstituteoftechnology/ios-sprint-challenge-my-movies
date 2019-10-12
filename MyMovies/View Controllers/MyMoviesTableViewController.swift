//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

protocol ToggleWatchedStatusDelegate {
    func toggleWatchedStatus(movie: Movie)
}

class MyMoviesTableViewController: UITableViewController {
    
    var movieController = MovieController()
    
    lazy var fetchResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "hasWatched", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func didRefresh(_ sender: Any) {
        movieController.fetchMoviesFromServer() { (_) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMoviesTableViewCell else { return UITableViewCell() }

        let movie = fetchResultsController.object(at: indexPath)
        
        cell.titleLabel.text = movie.title
        cell.movie = movie
        cell.watchedStatusDelegate = self
        
        if movie.hasWatched == false {
            cell.watchedStatusButton.setTitle("Not Watched", for: .normal)
        } else if movie.hasWatched == true {
            cell.watchedStatusButton.setTitle("Watched", for: .normal)
        }
        
        return cell
    }

     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let movie = fetchResultsController.object(at: indexPath)
             
            movieController.deleteMovieFromServer(movie: movie) { (error) in
                 if let error = error {
                     print("Error deleting movie from server: \(error)")
                     return
                 }
                 
                 // actions on the main context need to happen on the main thread
                 DispatchQueue.main.async {
                     let moc = CoreDataStack.shared.mainContext
                     moc.delete(movie)
                     
                     do {
                         try moc.save()
                     } catch {
                         moc.reset()
                         print("Error svaing managed object context: \(error)")
                     }
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchResultsController.sections?[section] else { return nil }
        
        var sectionTitle = sectionInfo.name
        if sectionTitle == "0" {
            sectionTitle = "Not Watched"
        } else if sectionTitle == "1" {
            sectionTitle = "Watched"
        }
        return sectionTitle
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            
            switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            default:
                break /// break == we're aware we're not handling stuff and intentionally doing that
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            case .update:
                guard let indexPath = indexPath else { return }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .move:
                guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
//                tableView.deleteRows(at: [oldIndexPath], with: .automatic)
//                tableView.insertRows(at: [newIndexPath], with: .automatic)
                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            case .delete:
                guard let indexPath = indexPath else { return }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            @unknown default:
                break
            }
        }
    
}

extension MyMoviesTableViewController: ToggleWatchedStatusDelegate {
    func toggleWatchedStatus(movie: Movie) {
        movieController.updateStatus(for: movie)
        tableView.reloadData()
    }
}

