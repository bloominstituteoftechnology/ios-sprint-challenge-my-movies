//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieTableViewCellDelegate {

    // MARK: Properties
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {fatalError("unable to dequeue tableview cell") }
        
        //cell.textLabel?.text = movieController.searchedMovies[indexPath.row]
        let movieRepresentation = movieController.searchedMovies[indexPath.row]
        cell.movieRepresentation = movieRepresentation
        cell.delegate = self
        
        return cell
    }
    
    func addMovie(for cell: MovieTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let movie = movieController.searchedMovies[indexPath.row]
        
        movieController.create(title: movie.title)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
}
