//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var myMovie: Movie? {
        didSet{
            updateViews()
        }
    }

    @IBAction func hasWatchedTapped(_ sender: UIButton) {
        myMovie?.toggleHasWatched()
        updateViews()
    }
    
    private func updateViews() {
        var buttonLabel: String = ""
        guard let myMovie = myMovie else { return }
        titleLabel.text = myMovie.title
        if myMovie.hasWatched {
            buttonLabel = "Watched"
        } else {
            buttonLabel = "Not Watched"
        }
        hasWatchedButton.setTitle(buttonLabel, for: .normal)
    }
}
