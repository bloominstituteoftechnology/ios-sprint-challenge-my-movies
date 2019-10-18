//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {

    
    // MARK: - properties
    let movieController = MovieController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchedRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let context = CoreDataStack.shared.mainContext
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: context, sectionNameKeyPath:"hasWatched", cacheName: nil)
        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        return fetchResultsController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieController.fetchMoviesFromServer()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MovieTableViewCell else {return UITableViewCell()}
        let movie = fetchedResultsController.object(at: indexPath)
        cell.movie = movie
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            self.movieController.deleteMovie(movie)
        }
    }
    
    // MARK: NSFetchedRequestController Delegate methods:
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
