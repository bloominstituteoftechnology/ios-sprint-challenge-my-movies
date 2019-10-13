//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel?.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 18).isActive = true
        cell.textLabel?.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -100).isActive = true
        cell.textLabel?.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        return cell
    }
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UITableViewCell,
            let title = cell.textLabel?.text,
            !title.isEmpty
        else {
            print("Nope")
            return
        }
        print("Yes: \(title)")
        MyMoviesController.shared.addMovie(title: title)
    }
    
    
}
