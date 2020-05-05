//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Chris Price on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

        let movieController = MovieController()
        var searchedMovie: MovieRepresentation? {
            didSet {
                updateViews()
            }
        }
        
        @IBOutlet weak var movieNameLabel: UILabel!
        
        @IBAction func addMovie(_ sender: Any) {
            guard let movie = searchedMovie else { return }
            // save 
        }
        
        // MARK: - Functions
        
        func updateViews() {
            movieNameLabel.text = searchedMovie?.title
        }
    }
