//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else {return}
        if movie.hasWatched {
            movieTitleLabel.text = movie.title
            hasWatchedButton.setTitle("Remove From List", for: .normal)
        } else {
            hasWatchedButton.setTitle("", for: .normal)
            movieTitleLabel.text = ""
        }
    }

}
