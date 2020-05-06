//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController {

//    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieController.sharedMovieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCell", for: indexPath) as? MovieSearchCell else { return UITableViewCell() }
        
        cell.movieRepresentation = MovieController.sharedMovieController.searchedMovies[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension MovieSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        MovieController.sharedMovieController.searchForMovie(with: searchTerm) { (error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension MovieSearchTableViewController: MovieSearchCellDelegate {
    func addToMyList(from cell: MovieSearchCell) {
        guard let movieRep = cell.movieRepresentation else { return }
            MovieController.sharedMovieController.saveMyMovieList(with: movieRep)
        }
    }
