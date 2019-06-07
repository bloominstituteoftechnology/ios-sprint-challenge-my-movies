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

    let mmc = MyMovieController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        MyMovieController.shared.fetchFromServer()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchReqeust: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchReqeust.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReqeust, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as! MovieTableViewCell

        // Configure the cell...
        let movieToPass = fetchedResultsController.object(at: indexPath)
        cell.movie = movieToPass
        return cell
    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let movieToDelete = fetchedResultsController.object(at: indexPath)
            //should this be done on a maincontext?
            MyMovieController.shared.delete(movie: movieToDelete)
        }
    }
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchedResultsController.sections?[section].name == "0" {
            return "UnWatched"
        }
        return "Watched"
    }
    //MARK: - NSFetchedResultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //what do we want to do to the table view based on the change type?
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            //insert a cell when we add a model object
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            //we need both indexpaths, from indexpath to newIndexpath
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
