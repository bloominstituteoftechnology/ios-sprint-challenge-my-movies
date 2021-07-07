//
//  MovieSearchTableViewController.swift
//  MyMovies2
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Ryan Murphy. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieTableViewCellDelegate {

   
  
        var myMovieController = MyMovieController()
        let movieTableViewCell = MovieTableViewCell()
        var movieController = MovieController()
        var movie: Movie?
        var movieRepresentation: MovieRepresentation?
        
        func addMovie(cell: MovieTableViewCell, movie: MovieRepresentation) {
            myMovieController.createMovie(title: movie.title, hasWatched: false)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else { fatalError()}
        cell.delegate = self
        cell.movieTitleLabel.text = movieController.searchedMovies[indexPath.row].title
        cell.movieRepresentation = movieController.searchedMovies[indexPath.row]
        
        return cell
    }
        
        
        
        @IBOutlet weak var searchBar: UISearchBar!
        
        
}
