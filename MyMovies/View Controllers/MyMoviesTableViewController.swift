//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController , LocalMovieCellDelegate {
    func didUpdateStatusForMovie(movie: Movie) {
        let newMovie = MovieRepresentation(title: movie.title!, identifier: movie.identifier, hasWatched: movie.hasWatched)
        movieController.put(movie: newMovie)
    }
    
    
    private let movieController = MovieController()
       
       lazy var fetchedResultsController : NSFetchedResultsController<Movie> = {
           let fetchRequest : NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.sortDescriptors = [
               NSSortDescriptor(key: #keyPath(Movie.title), ascending: true)
           ]
           
           let context = CoreDataStack.shared.mainContext
           let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(Movie.title), cacheName: nil)
           frc.delegate = self
           try? frc.performFetch()
           return frc
           
       }()
// MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          DispatchQueue.main.async {
              self.tableView.reloadData()
          }
        
      }
  

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return fetchedResultsController.sections?.count ?? 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          guard let cell = tableView.dequeueReusableCell(withIdentifier:"MyMovieCell", for: indexPath) as? LocalMovieCell else { return UITableViewCell()}
              cell.movie = fetchedResultsController.object(at: indexPath)
        cell.delegateTwo = self
              return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
          
          return "Watched"
      }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let movie = fetchedResultsController.object(at: indexPath)
            movieController.deleteMovieFromServer(movie: movie) { error in
                if let error = error {
                    NSLog("Error deleting entry from Firebase : \(error)")
                    return
                }
                DispatchQueue.main.async {
                    CoreDataStack.shared.mainContext.delete(movie)
                    do {
                        try CoreDataStack.shared.save()
                    } catch {
                        CoreDataStack.shared.mainContext.reset()
                        NSLog("Error saving managed object context: \(error)")
                    }
                }
                
                
            }
        
          
        }
    }
    

}
extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
            break
        }
    }
    
    
}
