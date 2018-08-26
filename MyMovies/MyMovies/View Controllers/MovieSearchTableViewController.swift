//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieCellDelegate
{
    // MARK: - Properties and Outlets
    
    var movieController = MovieController()
    @IBOutlet weak var searchBar: UISearchBar!
    var movie: MovieRepresentation?
    
    
    
    func toggleAddedMovie(cell: MovieListCell)
    {
        guard let indexPath = self.tableView.indexPath(for: cell) else {return}
        //print("button tapped on row \(indexPath.row)")
        movie = movieController.searchedMovies[indexPath.row]
        guard let title = movie?.title else {return}
        //movieController.createMovie(title: title)
        if movie == movie
        {
            print(movie!)
        }
        if cell.addMovieButton.currentTitle == "Add Movie"
        {
            cell.addMovieButton.setTitle("Added!", for: .normal)
            cell.addMovieButton.setTitleColor(UIColor.lightGray, for: .normal)
            movieController.createMovie(title: title)
        }
        else if cell.addMovieButton.currentTitle == "Added!"
        {
            cell.addMovieButton.setTitle("Add Movie", for: .normal)
            cell.addMovieButton.setTitleColor(UIColor.darkText, for: .normal)
            
        }
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieListCell
        
        let movie = movieController.searchedMovies[indexPath.row]
        cell.movie = movie
        cell.delegate = self
        return cell
    }
    
    
}
