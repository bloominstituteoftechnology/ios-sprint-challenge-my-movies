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
    
    //Properties
    var cdc = CoreDataController.shared
    var fbc = FirebaseController.shared
    
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //View Did Load Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        cdc.fetchResults.delegate = self
        fbc.getMovieOnFB()
        tableView.reloadData()
    }
    
    //Set up the Sections
    override func numberOfSections(in tableView: UITableView) -> Int {

        return cdc.fetchResults.sections?.count ?? 0
    }
    
    //Set up Section Headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cdc.fetchResults.sections?[section].name == "1" ? "Movies I've Seen" : "Movies I Haven't Seen"
    }

    //Set up the Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cdc.fetchResults.sections?[section].numberOfObjects ?? 0
    }

    //Set up the Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCellController
        
        cell.movie = cdc.fetchResults.object(at: indexPath)

        return cell
    }

    // Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // guard cdc.fetchResults.object(at: indexPath).isDeleted == false else { return }
            
            cdc.deleteMovie(movie: cdc.fetchResults.object(at: indexPath), index: indexPath)
        }
    }
    
    
//Instructions for the Fetch Results Controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // controller(_:didChange:atSectionIndex:for:)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete: tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move: tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
