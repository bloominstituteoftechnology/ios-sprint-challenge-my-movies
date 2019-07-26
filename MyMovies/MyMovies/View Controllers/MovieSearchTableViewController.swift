//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    let movieController = MovieController()
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieSearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.movie = movieController.searchedMovies[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
}

extension MovieSearchTableViewController: MovieSearchTableViewCellDelegate {
    func addMovieTapped(on cell: MovieSearchTableViewCell) {
        guard let movie = cell.movie else { return }
        let result = movieController.createMovie(title: movie.title, hasWatched: false)
        
        if result {
            cell.addMovieButton.setTitle("Added", for: .normal)
            cell.addMovieButton.isUserInteractionEnabled = false
        }
    }
}
