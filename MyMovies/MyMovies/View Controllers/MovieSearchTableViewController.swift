//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieSearchTableViewCellDelegate {

    // MARK: - Properties and Outlets
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.backgroundColor = Appearance.offEggplant
        searchBar.barTintColor = Appearance.eggplant
        searchBar.tintColor = Appearance.eggplant
    }
    
    // MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Cell Delegate Methods
    func addMovieButtonTapped(on cell: MovieSearchTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let movie = cell.movieRep else { return }
        
        movieController.create(from: movie)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell
        
        let movieRep = movieController.searchedMovies[indexPath.row]
        cell.movieRep = movieRep
        cell.delegate = self
        
        return cell
    }
}
