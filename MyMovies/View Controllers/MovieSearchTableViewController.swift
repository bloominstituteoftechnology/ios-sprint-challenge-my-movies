//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    struct PropertyKeys {
        static let cell = "MyMovieCell"
    }
    let movieController = MovieController()
    let myMoviesController = MyMoviesController()
    
    // MARK: - Lifecycle Methods
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.cell, for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        
        cell.myMoviesController = myMoviesController
        cell.movie = movieController.searchedMovies[indexPath.row]
        
        return cell
    }
    
}

//extension MovieSearchTableViewController: MovieCellDelegate {
//    func buttonTapped(for movie: MovieRepresentation) {
//        print("hi search")
//        Movie(title: movie.title)
//        do {
//            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
//            print("saved")
//        } catch {
//            print("Error saving movie to CoreData: \(error)")
//        }
//
//
//    }
//
//
//}
