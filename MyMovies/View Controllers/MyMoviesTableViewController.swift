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
    
    // MARK: - Properties
    
    let movieController = MovieController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
           let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
           
           let moc = CoreDataStack.shared.mainContext
           let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
           
           frc.delegate = self
           
           try! frc.performFetch()
           
           return frc
       }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.movieListCellString, for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        
        let movie = fetchedResultsController.object(at: indexPath)
        cell.movie = movie

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            
            movieController.deleteFromFireBase(movie: movie) { (error) in
                if let error = error {
                    NSLog("Error deleting entry: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    CoreDataStack.shared.mainContext.delete(movie)
                    do{
                        try CoreDataStack.shared.mainContext.save()
                    } catch {
                        CoreDataStack.shared.mainContext.reset()
                        NSLog("Error saving managed object context: \(error)")
                    }
                }
            }
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let searchVC = segue.
//    }
    
    // MARK: - NSFetchedResultsControllerDelegate
     
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.beginUpdates()
     }
     
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.endUpdates()
     }
     
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                     didChange sectionInfo: NSFetchedResultsSectionInfo,
                     atSectionIndex sectionIndex: Int,
                     for type: NSFetchedResultsChangeType) {
         switch type {
         case .insert:
             tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
         case .delete:
             tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
         default:
             break
         }
     }
     
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                     didChange anObject: Any,
                     at indexPath: IndexPath?,
                     for type: NSFetchedResultsChangeType,
                     newIndexPath: IndexPath?) {
         switch type {
         case .insert:
             guard let newIndexPath = newIndexPath else { return }
             tableView.insertRows(at: [newIndexPath], with: .automatic)
         case .update:
             guard let indexPath = indexPath else { return }
             tableView.reloadRows(at: [indexPath], with: .automatic)
         case .move:
             guard let oldIndexPath = indexPath,
                 let newIndexPath = newIndexPath else { return }
             tableView.deleteRows(at: [oldIndexPath], with: .automatic)
             tableView.insertRows(at: [newIndexPath], with: .automatic)
         case .delete:
             guard let indexPath = indexPath else { return }
             tableView.deleteRows(at: [indexPath], with: .automatic)
         @unknown default:
             return
         }
     }
     

}
