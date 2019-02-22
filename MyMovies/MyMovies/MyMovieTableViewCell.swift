//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Nathanael Youngren on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    @IBAction func watchStatusButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        updateController?.update(movie: movie, hasWatched: !movie.hasWatched)
        updateViews()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        if movie.hasWatched {
            watchStatusButton.setTitle("Watched", for: .normal)
        } else {
            watchStatusButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchStatusButton: UIButton!
    
    var updateController: UpdateController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
}
