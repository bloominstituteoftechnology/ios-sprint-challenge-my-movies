//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableVC: UITableViewController, UISearchBarDelegate {
    
    
    var movieController = MovieController()
    
    // MARK: - OULETS

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    
    // MARK: - ACTIONS
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - TABLEVIEW Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieSearchTableViewCell else { return UITableViewCell() }
        
        cell.movieLbl.text = movieController.searchedMovies[indexPath.row].title
        cell.movieSearchDelegate = self
        
        return cell
    }
    
}

extension MovieSearchTableVC: MovieSearchTVCDelegate {
    func saveMoviesToList(cell: MovieSearchTableViewCell) {
        guard let title = cell.movieLbl.text else { return }
        self.movieController.createMovie(title: title)
    }
    
    
}
