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
    
    var movieControllerRef = MovieController.shared
    var nsfetchres = MoviesManager.shared.fetchResults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nsfetchres.delegate = self as? NSFetchedResultsControllerDelegate
        MoviesManager().getMovieOnFB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType)
    {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default:
            break
        }
        
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
    
    //Stretch Goal
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return nsfetchres.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nsfetchres.sections?[section].name == "1" ? "Watched" : "Unwatched"
    }
    
    
    //Normal Goal
    
    //Number of rows in section should be the number of movies I've saved.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nsfetchres.sections?[section].numberOfObjects ?? 0
    }
    
    //Set up Cell to use my custom cell class or regular cell if it fails.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        guard let cell = basicCell as? MovieCell else {return basicCell}
        cell.movie = nsfetchres.object(at: indexPath)
        return cell
    }
    
    //Swipe to Delete.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MoviesManager().deleteMovie(movie: nsfetchres.object(at: indexPath))
        }
    }
}
