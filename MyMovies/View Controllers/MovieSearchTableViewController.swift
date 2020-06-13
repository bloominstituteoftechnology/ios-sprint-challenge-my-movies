//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var movieController = MovieController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                let movieDBMovie = movieController.searchedMovies[indexPath.row]
                let movie = Movie(title: movieDBMovie.title, hasWatched: false)
                movieController.sendMovieToServer(movie: movie)
                do {
                    try CoreDataStack.shared.save()
                } catch {
                    NSLog("Error saving movie: \(error)")
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier, for: indexPath) as? SearchResultTableViewCell else {
            fatalError("Could not dequeue cell: \(SearchResultTableViewCell.reuseIdentifier)")
        }
        cell.movieTitleLabel.text = movieController.searchedMovies[indexPath.row].title
        return cell
    }
}

extension MovieSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { result in
            if let _ = try? result.get() {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
