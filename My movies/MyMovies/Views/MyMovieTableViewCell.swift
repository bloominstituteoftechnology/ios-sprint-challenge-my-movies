//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Angelique Abacajan on 2/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//


import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!

    var movie: Movie? {
        didSet{
            updateViews()
        }
    }

    private func updateViews() {
        guard let movie = movie else { return }

        titleLabel.text = movie.title
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonTitle, for: .normal)
    }

}
