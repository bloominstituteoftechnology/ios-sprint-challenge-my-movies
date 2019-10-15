//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jessie Ann Griffin on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
    }

}
