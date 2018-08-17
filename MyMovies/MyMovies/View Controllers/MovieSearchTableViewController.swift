//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, SearchMovieCellDelegate, MoviePresenter
{
    var movieController: MovieController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func addMovie(with movie: MovieRepresentation)
    {
        let movie = Movie(title: movie.title)
        movieController?.uploadToDatabase(with: movie)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        guard let searchTerm = searchBar.text else { return }
        
        searchBar.resignFirstResponder()
        
        movieController?.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return movieController?.searchedMovies.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMovieCell", for: indexPath) as! SearchMovieCell
        
        cell.searchedMovieLabel.text = movieController?.searchedMovies[indexPath.row].title
        cell.movie = movieController?.searchedMovies[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

















