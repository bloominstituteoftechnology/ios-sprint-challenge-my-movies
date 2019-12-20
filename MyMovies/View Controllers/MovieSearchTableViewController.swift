//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    //MARK: Properties
    
    var movieController = MovieController()
    
    //MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    //MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MovieController.sharedInstance.createSavedMovie(title: MovieController.sharedInstance.searchedMovies[indexPath.row].title)
        
        let title = MovieController.sharedInstance.searchedMovies[indexPath.row].title
        
        let alert = UIAlertController(title: "\(title)", message: "Added to the list", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Return", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        MovieController.sharedInstance.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieController.sharedInstance.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        cell.textLabel?.text = MovieController.sharedInstance.searchedMovies[indexPath.row].title
        
        return cell
    }
    
}
