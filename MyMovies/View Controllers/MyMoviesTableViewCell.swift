//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_259 on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    // MARK: - Actions
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
    }
    
    
    // MARK: - View lifecycle
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setImage(UIImage(named: "square.fill"), for: .normal)
        } else {
            hasWatchedButton.setImage(UIImage(named: "square"), for: .normal)
        }
    }

}
