//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Zack Larsen on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MoviesTableViewCellDelegate?
    
    private func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
    }

    @IBAction func addMovieButton(_ sender: UIButton) {
        guard let movie = movie else { return }
        delegate?.addMovieToList(with: movie)
    }
}

