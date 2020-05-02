//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jarren Campos on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {

    var movieController: MovieController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    @IBAction func addMovieTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text,
            !movieTitle.isEmpty else { return }
        movieController?.createMovie(title: movieTitle, identifier: UUID(), hasWatched: false)
    }
    
    
}
