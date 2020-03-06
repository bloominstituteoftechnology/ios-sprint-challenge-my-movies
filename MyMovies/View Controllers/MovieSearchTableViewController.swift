//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieSearchTableViewCellDelegate {


    func addMovie(cell: MovieTableViewCell, movie: MovieRepresentation) {
           myMoviesController.createMovie(title: movie.title, hasWatched: false)
       }
       
       let movieTableViewCell = MovieTableViewCell()
       var movieController = MovieController()
       var movie: Movie?
       let myMoviesController = MyMoviesController.shared
       var movieRepresentation: MovieRepresentation?
       
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

       override func encodeRestorableState(with coder: NSCoder) {
           defer { super.encodeRestorableState(with: coder)}
           guard let movieRepresentation = movieRepresentation else { return }
             
           if let movieData = try? PropertyListEncoder().encode(movieRepresentation) {
           coder.encode(movieData, forKey: "movieData")
           }
       }
         
       override func decodeRestorableState(with coder: NSCoder) {
           defer { super.decodeRestorableState(with: coder)}
             
           guard let movieData = coder.decodeObject(forKey: "movieData") as? Data else { return }
           movieRepresentation = try? PropertyListDecoder().decode(MovieRepresentation.self, from: movieData)
         }
       
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return movieController.searchedMovies.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as? MovieTableViewCell else {
               fatalError("Could not dequeue cell")
           }
           
           cell.delegate = self

           let tappedMovie = movieController.searchedMovies[indexPath.row]
           
           cell.movieRepresentation = tappedMovie
           return cell
       }
    
    @IBOutlet weak var searchBar: UISearchBar!
}
