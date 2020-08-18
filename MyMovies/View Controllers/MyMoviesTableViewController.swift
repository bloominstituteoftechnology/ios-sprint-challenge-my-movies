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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Properties
    let movieController = MovieController()
    
    lazy var fetchResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest();       fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    @IBAction func refresh(_ sender: Any) {
           movieController.fetchMoviesFromServer { (_) in
               DispatchQueue.main.async {
                   self.refreshControl?.endRefreshing()
               }
           }
       }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections? [section].numberOfObjects ?? 0
    }
    
    //HAVE TO ADD REFRESH
    
    //    @IBAction func refresh(_ sender: Any) {
    //        movieController.fetchMoviesFromServer { (_) in
    //            DispatchQueue.main.async {
    //                self.refreshControl?.endRefreshing()
    //            }
    //        }
    //    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchResultsController.sections?[section] else {return nil}
        return sectionInfo.name.capitalized
    }
    
//    func tableViewSectionTitle(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        var sections: String {
//
//        switch section
//        {
//        case 0:
//            return "Not Watched"
//        case 1:
//            return "Watched"
//        default:
//            break
//        }
//        return section
//    }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as? MovieTableViewCell else { fatalError("Cannot deque cell \(MovieTableViewCell.reuseIdentifier)")}
        
        // Configure the cell...
        cell.delegate = self
        cell.movie = fetchResultsController.object(at: indexPath)
        return cell
    }
    
    //delete movies
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let movie = fetchResultsController.object(at: indexPath)
            movieController.deleteMoviesFromServer(movie) { (result) in
                guard let _ = try? result.get() else {return}
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                
                do {
                    try moc.save()
                    // tableView.reloadData()
                } catch {
                    moc.reset()
                    NSLog("Error saving \(error)")
                }
                
            }
        }
    }
    
}

extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
    //Updates
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    //Sections
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections((IndexSet(integer: sectionIndex)), with: .automatic)
        case .delete:
            tableView.deleteSections((IndexSet(integer: sectionIndex)), with: .automatic)
        default:
            break
        }
    }
    
    // Rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else {return}
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}

extension MyMoviesTableViewController: MovieCellDelegate {
    func didUpdateMovie(movie: Movie) {
        movieController.sendMovieToServer(movie: movie)
    }
}
