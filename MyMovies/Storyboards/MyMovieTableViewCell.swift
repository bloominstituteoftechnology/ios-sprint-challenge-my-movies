//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Elizabeth Thomas on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    var hasWatched = false
    var movieController: MovieController?

    // MARK: - IBOutlets
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        hasWatchedButton.setTitle("Watched", for: .normal)
    }
    
    private func updateViews() {
        titleLabel.text = movie?.title
    }
}
