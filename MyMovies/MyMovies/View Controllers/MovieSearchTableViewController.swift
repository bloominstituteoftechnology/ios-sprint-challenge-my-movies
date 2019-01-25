//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    let movieController = MovieController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reset search screen to original state
        if !(searchBar.text?.isEmpty)! {
            movieController.searchForMovie(with: " ") { (error) in
                guard error == nil else { return }
                
                DispatchQueue.main.async {
                    self.searchBar.text = nil
                    self.tableView.reloadData()
                }
            }
        }
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell
        
        cell.movieRepresentation = movieController.searchedMovies[indexPath.row]
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        return cell
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
}
