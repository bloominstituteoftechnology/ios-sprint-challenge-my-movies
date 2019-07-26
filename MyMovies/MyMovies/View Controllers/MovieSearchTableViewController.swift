//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, SearchMovieTableViewCellDelegate, NSFetchedResultsControllerDelegate {
    
    //Properties
    @IBOutlet weak var searchBar: UISearchBar!
    let movieController = MovieController()
    
    //MARK: Delegate is commented out. Throwing error
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: false), NSSortDescriptor(key: "title", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        frc.delegate = self
        
        try! frc.performFetch()
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: My Functions *****
    func addMovieToCoreData(for cell: SearchMovieTableViewCell) {
        
        guard let title = cell.titleLabel.text else { return }
        self.movieController.createMovie(withTitle: title)
        
    }
    
    func toggleHasBeenSeen(for cell: SearchMovieTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let movie = self.fetchedResultsController.object(at: indexPath)
        self.movieController.updateHasWatched(for: movie)
        
        tableView.reloadData()
    }


    
    
    //MARK: Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? SearchMovieTableViewCell else {return UITableViewCell()}
        
        let movie = self.fetchedResultsController.object(at: indexPath)
        cell.movie = movie
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = self.fetchedResultsController.object(at: indexPath)
            self.movieController.deleteMovie(withMovie: movie)
            
            //MARK: Might not need this???
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = self.fetchedResultsController.sections?[section] else { return nil }
        
        if sectionInfo.name == "0" {
            return "Unwatched"
        } else {
            return "Watched"
        }
    }
}


