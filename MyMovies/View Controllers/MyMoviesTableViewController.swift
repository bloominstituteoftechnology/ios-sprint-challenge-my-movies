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

private let movieController = MovieController()
   
     var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
          let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
          fetchRequest.sortDescriptors = [
              NSSortDescriptor(key: "title", ascending: true)
          ]
          let moc = CoreDataStack.shared.mainContext
          let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                               managedObjectContext: moc,
                                               sectionNameKeyPath: "hasWatched",
                                               cacheName: nil)
          frc.delegate = self
          //throws. a shortcut from the do-try-catch
          try! frc.performFetch()
          return frc
      }()//execute what is in here
      
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          tableView.reloadData()
      }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name.capitalized
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMoviesTableViewCell else { return UITableViewCell()}
        
        cell.movie = fetchedResultsController.object(at: indexPath)
        cell.delegate = self
    
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let movie = fetchedResultsController.object(at: indexPath)
            movieController.deleteMovieFromServer(movie)
        
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


}

//MARK: - Cell Delegate
extension MyMoviesTableViewController: MyMoviesCellDelegate {
    func hasWatchedButtonTapped(for movie: Movie) {
        movieController.toggleHasWatched(for: movie)
    }
    
    
}

//MARK: - Fetch Controller Delegate
extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //we are going to change the data
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    //sections change. insert, update,
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),  with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    //legacy code objc
    //optionals becuase optionals came move
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            //.automatic animations
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            //delete in old indexpath and insert in new indexpath
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
