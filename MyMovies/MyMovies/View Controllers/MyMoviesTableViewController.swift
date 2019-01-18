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
    
    //Properties
    var cdc = CoreDataController.shared
    var fbc = FirebaseController.shared
    
    
    //View Did Load Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        cdc.fetchResults.delegate = self as? NSFetchedResultsControllerDelegate
        fbc.getMovieOnFB()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
