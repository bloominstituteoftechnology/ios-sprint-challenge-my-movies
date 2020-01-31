//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 31/01/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        if let movie = movie {
            movieTitleLabel.text = movie.title
            addMovieButton.setTitle("Add Movie", for: .normal)
        }
    }
    
    @IBAction func addMovieTapped(_ sender: Any) {
        
    }
}
