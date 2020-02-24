//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by John Holowesko on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    
    // MARK: - Properties
    
    let movieController = MovieController()
    var searchedMovie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieName: UILabel!
    
    
    // MARK: - IBActions
    @IBAction func addMovie(_ sender: Any) {
        guard let movie = searchedMovie else {
            print("No movie to save")
            return
        }
        movieController.saveMovie(movie: movie)
    }
    
    // MARK: - Functions
    
    func updateViews() {
        movieName.text = searchedMovie?.title
    }
}
