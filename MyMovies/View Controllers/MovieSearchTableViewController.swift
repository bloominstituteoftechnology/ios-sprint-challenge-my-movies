//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: -Properties
    
    var movieController = MovieController()

    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)

           tableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieSearchTableViewCell else {
            fatalError("Could not dequeue cell as MovieCell")
        }

        cell.movie = movieController.searchedMovies[indexPath.row]
        cell.movieController = movieController
        cell.delegate = self
        return cell
    }
}
extension MovieSearchTableViewController: SearchMovieDelegate {
    func didChangeMovie() {
        tableView.reloadData()
    }
}

