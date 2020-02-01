//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    //MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Properties
    var movieController = MovieController()
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    //MARK: Searchbar delegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: APIMovieTableViewCell Delegate Method
    func alert() {
        Alert.show(title: "Oops!", message: "That movie was recently added to your list. Please tap \"My Movies\" at the bottom of your screen to see it.", vc: self)
    }
    
    //MARK: TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? APIMovieTableViewCell else {return UITableViewCell()}
        
        cell.movieRepresentation = movieController.searchedMovies[indexPath.row]
        cell.movieController = movieController
        cell.delegate = self
        return cell
    }
    
}
