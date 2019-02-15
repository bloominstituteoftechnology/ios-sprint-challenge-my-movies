//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieSearchTableCellDelegate {
    func addMovie(cell: MovieSearchTableViewCell, movie: MovieRepresentation) {
        myMoviesController.createMovie(title: movie.title, hasWatched:  false)
    }
    
    
    var movieController = MovieController()
    var myMoviesController = MyMoviesController()

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieSearchTableViewCell else {fatalError("Unable to dequeue cell as MovieSearchTableViewCell")}
        
      //  cell.titleLabel?.text = movieController.searchedMovies[indexPath.row].title
        
      //  cell.myMoviesController = myMoviesController
        
        let movies = movieController.searchedMovies[indexPath.row]
        cell.movieReprensetation = movies
        cell.delegate = self
        return cell
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
}
