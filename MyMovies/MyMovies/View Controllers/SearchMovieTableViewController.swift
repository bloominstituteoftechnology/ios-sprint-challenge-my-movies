//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewController: UITableViewController, SearchMovieTableViewCellDelegate, UISearchBarDelegate {
    
    //Properties
    var movieController = MovieController()
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    
    //My functions
    func addMovieToCoreData(for cell: SearchMovieTableViewCell) {
        guard let title = cell.titleLabel.text else { return }
        self.movieController.createMovie(withTitle: title)
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? SearchMovieTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = self.movieController.searchedMovies[indexPath.row].title
        cell.delegate = self
        
        return cell
    }
}
