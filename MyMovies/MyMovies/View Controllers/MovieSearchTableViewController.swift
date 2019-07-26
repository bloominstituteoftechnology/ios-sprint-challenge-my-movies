//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, SearchMovieTableViewCellDelegate {
    
    //Properties
    let movieController = MovieController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: false), NSSortDescriptor(key: "title", ascending: true)]
        
        let moc = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        //frc.delegate = self
        
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
    
    
    
    //MARK: Table Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? SearchMovieTableViewCell else {return UITableViewCell()}
        
        cell.titleLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        
        return cell
    }
    

    
    @IBOutlet weak var searchBar: UISearchBar!
}


