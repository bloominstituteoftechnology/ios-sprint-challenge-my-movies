//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: - Variables
    var movieController = MovieController()
    
    //MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!

    //MARK: - View LifeCycle
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
    
    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as?  MovieSearchTableViewCell else { return UITableViewCell() }
        cell.title = movieController.searchedMovies[indexPath.row].title
        cell.delegate = self
        return cell
    }
}

extension MovieSearchTableViewController: MovieSearchTableViewCellDelegate {
    func addMovieButtonTapped(sender: MovieSearchTableViewCell) {
        guard let index = tableView.indexPath(for: sender)?.row, index < movieController.searchedMovies.count else { return }
        let movieRepresentation = movieController.searchedMovies[index]
        movieController.create(movieRepresentation: movieRepresentation)
    }
}
