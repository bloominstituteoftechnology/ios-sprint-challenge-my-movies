//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var movieController = MovieController.shared
    
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
    
    //Number of movie search results to show
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    //Set up cell to use my custom cell class or default if it fails.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        guard let cell = basicCell as? SearchCell else { return basicCell }
        
        //cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        cell.movie = movieController.searchedMovies[indexPath.row]
        
        return cell
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
}
