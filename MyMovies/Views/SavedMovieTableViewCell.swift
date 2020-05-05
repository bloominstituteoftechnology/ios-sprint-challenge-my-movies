//
//  SavedMovieTableViewCell.swift
//  MyMovies
//
//  Created by Chris Price on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SavedMovieTableViewCell: UITableViewCell {
    let movieController = MovieController()
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var myMovieNameLabel: UILabel!
    @IBOutlet weak var watchedButtonLabel: UIButton!

    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movie = movie else { return }
        movieController.updateWatched(movie: movie)
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        myMovieNameLabel.text = movie.title
        let watchedButtonLabelString = movie.hasWatched ? "Watched" : "Unwatched"
        watchedButtonLabel.setTitle(watchedButtonLabelString, for: .normal)
    }
}
