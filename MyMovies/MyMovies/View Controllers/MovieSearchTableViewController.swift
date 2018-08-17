//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieControllerProtocol, MovieSearchTableViewCellDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController?.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController?.searchedMovies.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell
        
        cell.movieRepresentation = movieController?.searchedMovies[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    var movieController: MovieController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func saveMovie(for cell: MovieSearchTableViewCell) {
        guard let movieRepresentation = cell.movieRepresentation else { return }
        movieController?.create(movieRepresentation: movieRepresentation)
    }
}
