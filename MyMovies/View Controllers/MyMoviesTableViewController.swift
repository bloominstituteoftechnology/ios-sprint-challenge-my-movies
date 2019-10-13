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

    let myMovieController = MyMovieController()

    //create your fetchController that will be in charge of updating the view
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchReqeust: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        //fetchedResultsController NEEDS sort descriptors or it wont know how to populate the table View
        fetchReqeust.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReqeust, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        //set the delegate to self
        fetchedResultsController.delegate = self
        do {
            //call performFetch on your FRC
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetchedResultsController: \(error)////  \(error.localizedDescription)")
        }
        //don't forget to reutrn your frc
        return fetchedResultsController
    }()
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name == "0" ? "UnWatched" : "Watched"

        
//        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil}
//        return sectionInfo.name.capitalized
//        return fetchedResultsController.sections?[section].name.capitalized
//        return fetchedResultsController.sectionIndexTitles[section].count = 0 ? "Watched" : "UnWatched"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myMovieCell", for: indexPath) as! MovieCellTableViewCell
        let movie = fetchedResultsController.object(at: indexPath)
        cell.movie = movie
        // Configure the cell...

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          
            let movieToDelete = fetchedResultsController.object(at: indexPath)
            //this is happening on a main thread so it can be done on the regular context
            MyMovieController.shared.delete(movie: movieToDelete)
        }
    }
}

//MARK: - NSFetchedResultsController Delegate Methods

extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
    
    //will tell the tableViewController get ready to do something.
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
            //there was a new entry so now we need to make a new cell.
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath, let newIndexpath = newIndexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexpath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSSet, with: .automatic)
        default:
            break
        }
    }
}
