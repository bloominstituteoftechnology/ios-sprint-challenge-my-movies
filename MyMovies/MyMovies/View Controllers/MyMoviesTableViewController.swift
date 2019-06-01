//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    let myMoviesController = MyMoviesController()

    // MARK: View states functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
         return fetchedResultsController.sections?[section].name.capitalized
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as! DBMovieListCell
     
     // Configure the cell...
        let movie = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = movie.title
        
     return cell
     }
    
    
    // MARK: - Properties
    
    
    // MARK: - Functions
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                                              NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NSLog("Error performing initial fetch for frc: \(error)")
        }
        return fetchedResultsController
    }()
/* ======================================================================== */
    
    
    
    
    
    
    
    
    
    
    



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
