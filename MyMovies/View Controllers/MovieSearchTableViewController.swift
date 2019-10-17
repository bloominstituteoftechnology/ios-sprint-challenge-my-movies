//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

protocol AddMovieDelegate {
    func addMovie(movieRepresentation: MovieRepresentation)
}

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        
        let movie = movieController.searchedMovies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.addMovieButton.setTitle("Add Movie", for: .normal)
        cell.movieController = movieController
        cell.movieDelegate = self
        cell.movieRepresentation = movie
        
        return cell
    }
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
}

extension MovieSearchTableViewController: AddMovieDelegate {
    func addMovie(movieRepresentation: MovieRepresentation) {
        movieController.addMovie(movieRepresentation)
    }
}


