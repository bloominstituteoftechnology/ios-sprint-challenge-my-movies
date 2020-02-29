//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit


class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate{

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    // MARK: - Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.movieCellString, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        cell.movieController = movieController
        
        return cell
    }
    
    // MARK: - Properties
    
    var movieController = MovieController()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
}
