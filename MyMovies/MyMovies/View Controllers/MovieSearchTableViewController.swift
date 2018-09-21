//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    
    // MARK:- View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shouldRemoveShadow(true)
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
    }
    
    
    // MARK:- UISearchBar delegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK:- UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCell", for: indexPath) as? MovieSearchTableViewCell else { return UITableViewCell() }
        
        cell.movieTitle = movieController.searchedMovies[indexPath.row].title
        cell.movieController = movieController
        
        return cell
    }
    
    
    // MARK:- Properties & types
    let movieController = MovieController.shared
    
    // MARK:- IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
}
