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
    
    //MARK: - Properties
    var movieController = MovieController()
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    //MARK: - Search Method
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else { return UITableViewCell()}
        
        cell.title = movieController.searchedMovies[indexPath.row].title
        cell.delegate = self
        
        return cell
    }
}

extension MovieSearchTableViewController: MovieSearchCellDelegate {
    func addMovieButtonTapped(sender: MovieTableViewCell) {
        guard let index = tableView.indexPath(for: sender)?.row else { return }
        
        let movieRepresentation = movieController.searchedMovies[index]
        
        movieController.createMovie(from: movieRepresentation)
    }
}
