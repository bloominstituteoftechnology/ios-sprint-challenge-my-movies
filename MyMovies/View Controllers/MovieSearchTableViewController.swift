//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit


protocol AddMovieDelegate {
    func addMovie(movieRepresentation: MovieRepresentation)
}



class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    
     var movieController = MovieController()
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCellIdentifier", for: indexPath) as? MovieSearchCell else {return UITableViewCell() }
        
        let movie = movieController.searchedMovies[indexPath.row]
        
        cell.movieNameLabel.text = movie.title
        cell.addMovieButton.setTitle("Add Movie", for: .normal)
        cell.movieController = movieController
        cell.addMovieDelegate = self
        cell.movieRepresentation = movie
        
        return cell
        
    }
    
   
    
    @IBOutlet weak var searchBar: UISearchBar!
}

extension MovieSearchTableViewController: AddMovieDelegate {
    func addMovie(movieRepresentation: MovieRepresentation) {
        movieController.addMovie(movieRepresentation)
    }
}


