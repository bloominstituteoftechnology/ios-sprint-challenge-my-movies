//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController {

    //MARK: - Properties
    var movieController = MovieController()
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    //MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieSearchTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.movieRepresentation = movieController.searchedMovies[indexPath.row]
        
        return cell
    }
    
    
}

//MARK: - Extensions
extension MovieSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           guard let searchTerm = searchBar.text else { return }
           
           movieController.searchForMovie(with: searchTerm) { (error) in
               
               guard error == nil else { return }
               
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
}

extension MovieSearchTableViewController: MovieWasAddedDelegate {
    func movieWasAdded(movie: MovieRepresentation) {
        movieController.saveMovie(movieRepresentation: movie)
    }
}
