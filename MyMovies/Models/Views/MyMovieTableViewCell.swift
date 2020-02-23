//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Sal Amer on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    let movieController = MovieController()
    // IB Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    private func updateViews() {
        guard let movie = movie else { return }
//        movieNameLbl.text = movie.title
        titleLabel.text = movie.title
        
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonTitle, for: .normal)
    }

}
