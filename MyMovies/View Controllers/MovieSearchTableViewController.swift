//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    var apiClient = APIClient()
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    
    // MARK: - Search Bar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        apiClient.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table View Data Source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiClient.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCell", for: indexPath) as? MovieSearchTableViewCell else {
            fatalError("Unable to cast cell as MovieSearchTableViewCell")
        }
        
        let movieRepresentation = apiClient.searchedMovies[indexPath.row]
        
        cell.movieRepresentation = movieRepresentation
        cell.addMovieCallback = { representation in
            MovieController.shared.addMovie(with: representation)
        }
        
        return cell
    }
}


