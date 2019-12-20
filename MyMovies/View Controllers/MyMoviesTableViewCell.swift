//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Patrick Millet on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
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
