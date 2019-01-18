//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
import CoreData
import UIKit

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let myMoviesController = MyMoviesController()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let frc = CoreDataStack.shared.makeNewFetchedResultsController()

//        let predicate = NSPredicate(format: "hasWatched == %@", true)
//        frc.fetchRequest.predicate = predicate

        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    @IBAction func beginRefresh(_ sender: UIRefreshControl) {
        myMoviesController.fetchMoviesFromServer { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                sender.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as! MyMoviesTableViewCell
        
        let movie = fetchedResultsController.object(at: indexPath)
        cell.myMovieTitleLabel.text = movie.title
        
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let movie = fetchedResultsController.object(at: indexPath)
        //FIXME: Movie is saving with NO IDENTIFIER 🤬
        guard let movieIdentifier = movie.identifier else {
            print("movie has no identifier!")
            return
        }
        myMoviesController.delete(movieWithIdentifier: movieIdentifier)
        CoreDataStack.shared.mainContext.delete(movie)
        try! CoreDataStack.shared.mainContext.save()
//        do {
//            try CoreDataStack.shared.mainContext.save()
//            if let identifier = movieIdentifier {
//                myMoviesController.delete(movieWithIdentifier: identifier)
//            }
//        } catch {
//            print("Failed to delete movie: \(error)")
//        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRows(at: [indexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }

}
