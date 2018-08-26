//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, MyMoviesCellDelegate
{
    private let movieController = MovieController()
    var movies = [Movie]()
    var movie: Movie?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        frc.delegate = self
        
        try! frc.performFetch()
        
        return frc
    }()
    
    func toggleWatchedMovie(cell: MyMoviesCell)
    {
        guard let indexPath = self.tableView.indexPath(for: cell) else {return}
        print("button tapped on row \(indexPath.row)")
        movie = fetchedResultsController.object(at: indexPath)
        movie?.hasWatched = !(movie?.hasWatched)!
        movieController.put(movie: movie!)
        
        
        print(movie!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return fetchedResultsController.sections?[section].name == "0" ? "Need To Watch" : "Watched!"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as! MyMoviesCell
     
        let movie = fetchedResultsController.object(at: indexPath)
        //cell.titleLabel.text = movie.title
        cell.movie = movie
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let movie = fetchedResultsController.object(at: indexPath)
            movieController.deleteMovieFromServer(movie) { (error) in
                if let error = error
                {
                    NSLog("Error deleting task from server: \(error)")
                    return
                }
                
                let moc = movie.managedObjectContext
                moc?.perform {
                    moc?.delete(movie)
                    
                    do
                    {
                        try moc?.save()
                    }
                    catch
                    {
                        moc?.reset()
                        NSLog("Error saving managed object context: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else {return}
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

}
