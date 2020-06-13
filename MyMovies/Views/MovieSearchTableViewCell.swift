//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Chris Price on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonTapped(sender: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {

        let movieController = MovieController()
        var searchedMovie: MovieRepresentation? {
            didSet {
                updateViews()
            }
        }
        
        @IBOutlet weak var movieNameLabel: UILabel!
        
        @IBAction func addMovie(_ sender: Any) {
            print("This addMovie func worked number 1")
            guard var movie = searchedMovie else { return }
            print("\(movie.title)")
            movie.identifier = UUID()
            movie.hasWatched = false
            print("This addMovie func worked number 2 \(movie.identifier!)")
            guard let newMovie = Movie(movieRepresentation: movie) else { return }
            print("This addMovie func worked number 3")
            movieController.put(movie: newMovie) { (result) in
                DispatchQueue.main.async {
                    print(result)
                }
            }
        }
        
        // MARK: - Functions
        
        func updateViews() {
            movieNameLabel.text = searchedMovie?.title
        }
    }
