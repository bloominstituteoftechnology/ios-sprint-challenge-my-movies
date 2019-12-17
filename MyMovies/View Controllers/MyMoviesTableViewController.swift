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

    let movieController = MovieController()
        
        lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "title", ascending: true),
                NSSortDescriptor(key: "hasWatched", ascending: true)
            ]
            
            let moc = CoreDataStack.shared.mainContext
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                 managedObjectContext: moc,
                                                 sectionNameKeyPath: "hasWatched",
                                                 cacheName: nil)
            frc.delegate = self
            do {
                try frc.performFetch()
            } catch {
                print("Error fetching: \(error)")
            }
            return frc
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()

            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false

            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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

        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMoviesTableViewCell else { return UITableViewCell() }

            // Configure the cell...
            let movie = fetchedResultsController.object(at: indexPath)
            cell.movie = movie
            return cell
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
            
            return (sectionInfo.name == "0") ? "Not Watched" : "Watched"
        }
        
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                let movie = fetchedResultsController.object(at: indexPath)
                            movieController.delete(for: movie)
                            let moc = CoreDataStack.shared.mainContext
                            do {
                                try moc.save()
                                tableView.reloadData()
                            } catch {
                                moc.reset()
                                print("error saving managed object context: \(error)")
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
                guard let oldIndexPath = indexPath else { return }
                guard let newIndexPath = newIndexPath else { return }
                tableView.deleteRows(at: [oldIndexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            case .delete:
                guard let indexPath = indexPath else { return }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            default:
                break
            }
        }
    }

