//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Craig Swanson on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
    }

    @IBAction func addMoviePressed(_ sender: UIButton) {
    }
    
}
