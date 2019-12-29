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
    let apiController = APIController()
    
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Movies> = {
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true),
            NSSortDescriptor(key: "hasWatched", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: "hasWatched",
            cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
//        myMoviesTableViewCell.updateWatchStatus()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("There are \(fetchedResultsController.sections?.count) sections")
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("There are \(fetchedResultsController.sections?[section].numberOfObjects) Rows")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movies = fetchedResultsController.object(at: indexPath)
            DispatchQueue.main.async {
                    let moc = CoreDataStack.shared.mainContext
                    moc.delete(movies)
                    do {
                        try moc.save()
                        tableView.reloadData()
                    } catch {
                        moc.reset()
                        print("Error saving: \(error)")
                        tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath)
        let movie = fetchedResultsController.object(at: indexPath)
        let label = UILabel()
        let button = UIButton()
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5).isActive = true
        stackView.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor).isActive = true
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
    
        label.text = movie.title
        label.autoresizesSubviews = true

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: .normal)
        if movie.hasWatched == true {
            button.setTitle(WatchStatus.watched.rawValue, for: .normal)
        } else if movie.hasWatched == false {
            button.setTitle(WatchStatus.notWatched.rawValue, for: .normal)
        }
        button.addTarget(self, action: #selector(updateWatchStatus(button:movie:)), for: .touchUpInside)
        cell.contentView.addSubview(button)
       
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        if sectionInfo.name == "0" {
            return "Not Watched"
        } else {
            return "Watched"
        }
    }
    

    @objc func updateWatchStatus(button: UIButton, movie: Movies) {
        let NewMovie = MovieRepresentation(title: movie.title, identifier: movie.identifier, hasWatched: movie.hasWatched)
          DispatchQueue.main.async {
            if button.titleLabel?.text == "Not Watched" {
                button.setTitle(WatchStatus.watched.rawValue, for: .normal)
                movieController.update(with: movie)
            } else if button.titleLabel?.text == "Watched" {
                button.setTitle(WatchStatus.notWatched.rawValue, for: .normal)
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
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default: return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let sectionSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                tableView.insertSections(sectionSet, with: .automatic)
            case .delete:
                tableView.deleteSections(sectionSet, with: .automatic)
            default: return
        }
        
    }
}
