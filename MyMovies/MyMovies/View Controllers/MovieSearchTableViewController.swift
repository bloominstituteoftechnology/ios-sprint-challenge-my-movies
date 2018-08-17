//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate
{
    var movie: Movie?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        cell.searchTitleLabel.text = movieController.searchedMovies[indexPath.row].title
        
        return cell
    }
    
    @IBAction func addMovie(_ sender: Any)
    {
        print("button tapped")
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        let movie = movieController.searchedMovies[indexPath.row]
        if movie == movie
        {
            movieController.createMovie(title: movie.title, identifier: movie.identifier!, hasWatched: movie.hasWatched!)
        }
    }
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
}
