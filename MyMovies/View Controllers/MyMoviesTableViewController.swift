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

    let myMoviesController = MyMovieController()

    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
           let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.sortDescriptors = [
               NSSortDescriptor(key: "hasWatched", ascending: true),
               NSSortDescriptor(key: "title", ascending: true)
           ]

           let moc = CoreDataStack.shared.mainContext
           let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: moc,
                                                sectionNameKeyPath: "hasWatched",
                                                cacheName: nil)

           frc.delegate = self

           do {
               try frc.performFetch()
           }catch {
               NSLog("Error fetching Movie objects")
           }

           return frc
       }()

 override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)

     tableView.reloadData()
 }

    @IBAction func refreshData(_ sender: Any) {
           myMoviesController.fetchMovieFromServer { (_) in
               self.refreshControl?.endRefreshing()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyMovieTableViewCell.reuseIdentifier, for: indexPath) as? MyMovieTableViewCell else {
            fatalError("Can't dequeue cell of type \(MyMovieTableViewCell.reuseIdentifier)")
        }
        cell.delegate = self
        cell.myMoviesController = myMoviesController
        cell.movie = fetchedResultsController.object(at: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section].name else { return "" }
        switch sectionInfo {
        case "0":
            return "Not Watched"
        default:
            return "Watched"
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
                let movie = fetchedResultsController.object(at: indexPath)
                myMoviesController.deleteMovieFromServer(movie) { (result) in
                    guard let _ = try? result.get() else { return }
                    DispatchQueue.main.async {
                        let moc = CoreDataStack.shared.mainContext
                        moc.delete(movie)
                        do {
                            try moc.save()
                            tableView.reloadData()
                        } catch {
                            moc.reset()
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
                break
            }
        }
}

extension MyMoviesTableViewController: MyMovieTableViewCellDelegate {
    func didUpdateMovie(movie: Movie) {
        myMoviesController.sendMovieToServer(movie: movie)
    }
}
