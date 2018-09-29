//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieSearchTableViewCellDelegate {

    func saveMovieToList(cell: MovieSearchTableViewCell) {
        guard let title = title else { return }
        
        movieController.create(title: title)
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        guard let MovieCell = cell as? MovieSearchTableViewCell else { return cell }
        
        let movie = movieController.searchedMovies[indexPath.row].title
        
        MovieCell.textLabel?.text = movie
        MovieCell.delegate = self
        
        return cell
    }
    
    // Set up movie cell delegate
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
}
